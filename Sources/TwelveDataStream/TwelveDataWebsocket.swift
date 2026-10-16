//
//  Created by Kurlovich Vitali on 9/26/26.
//

import Foundation
import StreamWebSocket

#if TwelveDataStreamLogging
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
            await coordinator.setSocket(self)

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

    private let socket: WebSocket

    private let priceEvents: AsyncStream<TwelvedataPriceEvent>
    private let priceEventsContinuation: AsyncStream<TwelvedataPriceEvent>.Continuation

    private var socketEventsTask: Task<Void, Never>?

    private var sceduleSubscriptionInvalidationTask: Task<Void, Never>?

    private var coordinator = SubscriptionsCoordinator()
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
    func update(apiKey: String) {
        configuration.apiKey = apiKey
    }

    func update(baseUrl: URL) {
        configuration.baseUrl = baseUrl
    }

    func update(configuration: Configuration) {
        self.configuration = configuration
    }
}

public extension TwelveDataWebsocket {
    var state: State {
        get async {
            await State(socket.state)
        }
    }

    var states: AsyncStream<State> {
        AsyncStream<State>(
            bufferingPolicy: .bufferingNewest(1)
        ) { continuation in
            let task = Task {

                for await state in await socket.states {
                    let state = State(state)
                    continuation.yield(state)

                    #if TwelveDataStreamLogging
                        logger.debug("Send state change to stream: \(state)")
                    #endif
                }
                continuation.finish()

                #if TwelveDataStreamLogging
                    logger.debug("Finish state stream")
                #endif
            }

            continuation.onTermination = { _ in
                task.cancel()

                #if TwelveDataStreamLogging
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
                }
                continuation.finish()

                #if TwelveDataStreamLogging
                    logger.debug("Finish prices stream")
                #endif
            }

            continuation.onTermination = { _ in
                task.cancel()
                #if TwelveDataStreamLogging
                    logger.debug("Csncel prices stream")
                #endif
            }
        }
    }

    func subscribe<S: Sequence>(symbols insert: S) async throws where S.Element == String {
        try await coordinator.subscribe(.init(insert))

        if await coordinator.subscriptions.isEmpty == false, await socket.state != .connected {
            await socket.connect()
        }
    }

    func unsubscribe<S: Sequence>(symbols removed: S) async throws where S.Element == String {
        try await coordinator.unsubscribe(.init(removed))

        if await coordinator.subscriptions.isEmpty, await socket.state == .connected {
            await socket.disconnect()
        }
    }
}

extension TwelveDataWebsocket {
    func recieve(price: TwelvedataPriceEvent) {
        priceEventsContinuation.yield(price)
    }

    func send(_ request: TwelveDataRequest) async throws {
        let encoder = JSONEncoder()

        let data = try encoder.encode(request)

        if let json = String(data: data, encoding: .utf8) {
            try await socket.send(json)

            #if TwelveDataStreamLogging
                logger.info("Send:\(json)")
            #endif
        }
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
                do {
                    try await coordinator.connect()
                } catch {
                    #if TwelveDataStreamLogging
                        logger.error("\(error.localizedDescription)")
                    #endif
                }

                #if TwelveDataStreamLogging
                    logger.info("Connect to server")
                #endif

            case .onDisconnet:
                await coordinator.disconnect()

                #if TwelveDataStreamLogging
                    logger.info("Disconnect from server")
                #endif

            case let .didCompleteWithError(_, _, error):
                await coordinator.disconnect()

                #if TwelveDataStreamLogging
                    guard let error else { return }
                    logger
                        .error(
                            "didCompleteWithError from server: \(error.localizedDescription)"
                        )
                #endif
            }
        }
    }

    func subscribeMessages() async {
        for await message in await socket.messages {
            switch message {
            case let .data(data):
                await onMessage(data)

            case let .text(string):
                if let data = string.data(using: .utf8) {
                    await onMessage(data)
                } else {
                    #if TwelveDataStreamLogging
                        logger.error("Can't convert string to Data \(string)")
                    #endif
                }
            }
        }
    }

    func onMessage(_ json: Data) async {
        do {
            let event = try TwelvedataEvent.decode(from: json)

            #if TwelveDataStreamLogging
                if let string = String(data: json, encoding: .utf8) {
                    switch event {
                    case .price:
                        logger.debug("Recieve: \(string)")
                    default:
                        logger.info("Recieve: \(string)")
                    }
                }
            #endif

            try await coordinator.on(event: event)

        } catch {
            #if TwelveDataStreamLogging
                logger.error("Catch error: \(error.localizedDescription)")
            #endif
        }
    }

    func invalidateConfiguration() {
        Task {
            await socket.update(configuration: .init(configuration))
        }
        #if TwelveDataStreamLogging
            logger.debug("Update configuration")
        #endif
    }
}
