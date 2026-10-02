//
//  Created by Kurlovich Vitali on 9/26/26.
//

import Foundation
import StreamWebSocket

#if TwelveDataLogging
    import Logging

    private let logger: Logger = .init(label: String(describing: TwelveDataWebsocket.self))
#endif

public actor TwelveDataWebsocket {
    public typealias Configuration = TwelveDataWebsocketConfiguration
    public typealias State = TwelveDataWebsocketState
    public typealias Price = TwelvedataPriceEvent

    public init(configuration: Configuration, sessionConfiguration: URLSessionConfiguration = .default) {
        self.configuration = configuration
        let socket = WebSocket(
            configuration: .init(configuration),
            sessionConfiguration: sessionConfiguration,
            pingUpdater: TwelvedataHeartbeat()
        )

        self.socket = socket

        let (priceStream, priceContinuation) = AsyncStream<TwelvedataPriceEvent>.makeStream()
        priceEvents = priceStream
        priceEventsContinuation = priceContinuation

        Task {
            await subscribeSocketEventsIfNeeds()
            await subscribeMessages()
        }
    }

    public var configuration: Configuration {
        didSet {
            if oldValue != configuration {
                invalidateConfiguration()
            }
        }
    }

    public private(set) var symbols: Set<String> = [] {
        didSet {
            if oldValue != symbols {
                symbolsDidChange()
            }
        }
    }

    private let socket: WebSocket

    private let priceEvents: AsyncStream<TwelvedataPriceEvent>
    private let priceEventsContinuation: AsyncStream<TwelvedataPriceEvent>.Continuation

    private var socketEventsTask: Task<Void, Never>?

    public private(set) var subscribed: Set<String> = [] {
        didSet {
            if oldValue != subscribed {
                symbolsDidChange()
            }
        }
    }

    public private(set) var faild: Set<String> = [] {
        didSet {
            if oldValue != subscribed {
                symbolsDidChange()
            }
        }
    }
}

public extension TwelveDataWebsocket {
    init(apiKey: String, sessionConfiguration: URLSessionConfiguration = .default) {
        let configuration = Configuration(apiKey: apiKey)
        self.init(configuration: configuration, sessionConfiguration: sessionConfiguration)
    }

    init(
        baseUrl: URL,
        apiKey: String,
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        let configuration = Configuration(baseUrl: baseUrl, apiKey: apiKey)
        self.init(configuration: configuration, sessionConfiguration: sessionConfiguration)
    }
}

public extension TwelveDataWebsocket {
    var state: State {
        get async {
            await State(socket.state)
        }
    }

    var states: AsyncStream<State> {
        AsyncStream<State> { continuation in
            let task = Task {

                continuation.yield(await state)

                for await state in await socket.states {
                    let state = State(state)
                    continuation.yield(state)

                    #if TwelveDataLogging
                        logger.debug("Send state change to stream: \(state)")
                    #endif
                }
                continuation.finish()

                #if TwelveDataLogging
                    logger.debug("Finish state stream")
                #endif
            }

            continuation.onTermination = { _ in
                task.cancel()

                #if TwelveDataLogging
                    logger.debug("Cancel state stream")
                #endif
            }
        }
    }

    var prices: AsyncStream<Price> {
        AsyncStream<Price> { continuation in
            let task = Task {
                for await price in priceEvents {
                    continuation.yield(price)

                    #if TwelveDataLogging
                        logger.debug("Send price to stream: \(price)")
                    #endif
                }
                continuation.finish()

                #if TwelveDataLogging
                    logger.debug("Finish prices stream")
                #endif
            }

            continuation.onTermination = { _ in
                task.cancel()
                #if TwelveDataLogging
                    logger.debug("Csncel prices stream")
                #endif
            }
        }
    }

    func subscribe<S: Sequence>(symbols insert: S) where S.Element == String {
        symbols = symbols.union(insert)

        #if TwelveDataLogging
            logger.debug("Subscribe symbols:\(insert)")
        #endif
    }

    func unsubscribe<S: Sequence>(symbols removed: S) where S.Element == String {
        symbols = symbols.subtracting(removed)

        #if TwelveDataLogging
            logger.debug("Unsubscribe symbols:\(removed)")
        #endif
    }
}

private extension TwelveDataWebsocket {
    func subscribeSocketEventsIfNeeds() {
        guard socketEventsTask == nil else { return }
        socketEventsTask = Task {
            await subscribeSocketEvents()
        }
    }

    func subscribeSocketEvents() async {
        for await event in await socket.events {
            switch event {
            case .onConnect:
                symbolsDidChange()

                #if TwelveDataLogging
                    logger.info("Connect to server")
                #endif

            case .onDisconnet:
                subscribed = []

                #if TwelveDataLogging
                    logger.info("Disconnect to server")
                #endif
            }
        }
    }

    func subscribeMessages() async {
        for await message in await socket.messages {
            switch message {
            case let .data(data):
                onMessage(data)

            case let .text(string):
                if let data = string.data(using: .utf8) {
                    onMessage(data)
                } else {
                    #if TwelveDataLogging
                        logger.error("Can't convert string to Data \(string)")
                    #endif
                }
            }
        }
    }

    func onMessage(_ json: Data) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        do {
            let response = try decoder.decode(TwelvedataEventResponse.self, from: json)

            switch response.event {
            case .price:
                let price = try decoder.decode(TwelvedataPriceEvent.self, from: json)

                priceEventsContinuation.yield(price)
                #if TwelveDataLogging
                    logger.debug("Recieve price: \(price)")
                #endif

            case .subscribeStatus:
                guard let subscribeStatus = try? decoder.decode(TwelveDataSubscribeStatusEvent.self, from: json) else {
                    return
                }

                let success = subscribeStatus.success?.map(\.symbol) ?? []

                subscribed = subscribed.union(success)

                let failsSubscriptions = subscribeStatus.fails?.map(\.symbol) ?? []

                faild = faild.union(failsSubscriptions)
                #if TwelveDataLogging
                    logger.debug("Recieve subscribeStatus: success:\(success), faild:\(faild)")
                #endif

            case .heartbeat:
                #if TwelveDataLogging
                    logger.debug("Recieve heartbeat")
                #endif
            }

        } catch {
            #if TwelveDataLogging
                logger.error("Catch error: \(error.localizedDescription)")
            #endif
        }
    }

    func symbolsDidChange() {
        Task {
            do {
                try await invalidateSubscription()
            } catch {
                #if TwelveDataLogging
                    logger.error("Catch error: \(error.localizedDescription)")
                #endif
            }
        }
    }

    func invalidateSubscription() async throws {
        if symbols.isEmpty {
            await socket.disconnect()
            return
        }

        guard await socket.state == .connected else {
            await socket.connect()
            return
        }

        let needsSubsribe = symbols.subtracting(subscribed).subtracting(faild)
        let needsUnSubsribe = subscribed.subtracting(symbols)

        let encoder = JSONEncoder()

        if needsSubsribe.isEmpty == false {
            let subscribeRequest = TwelveDataRequest.subscribe(needsSubsribe)

            let data = try encoder.encode(subscribeRequest)
            if let json = String(data: data, encoding: .utf8) {
                try await socket.send(json)
            }

            #if TwelveDataLogging
                logger.debug("Subscribe for: \(needsSubsribe)")
            #endif
        }

        if needsUnSubsribe.isEmpty == false {
            let unsubscribeRequest = TwelveDataRequest.unsubscribe(needsUnSubsribe)

            let data = try encoder.encode(unsubscribeRequest)
            if let json = String(data: data, encoding: .utf8) {
                try await socket.send(json)
            }

            #if TwelveDataLogging
                logger.debug("Unsubscribe for: \(needsUnSubsribe)")
            #endif
        }
    }

    func invalidateConfiguration() {
        Task {
            await socket.update(configuration: .init(configuration))
        }
        #if TwelveDataLogging
            logger.debug("Update configuration")
        #endif
    }
}
