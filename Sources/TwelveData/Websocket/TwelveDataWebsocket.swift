//
//  Created by Kurlovich Vitali on 9/26/26.
//

import Foundation
import StreamWebSocket

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
    var state: AsyncStream<State> {
        AsyncStream<State> { continuation in
            let task = Task {
                for await state in await socket.states {
                    continuation.yield(State(state))
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
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
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    func subscribe<S: Sequence>(symbols insert: S) where S.Element == String {
        symbols = symbols.union(insert)
    }

    func unsubscribe<S: Sequence>(symbols removed: S) where S.Element == String {
        symbols = symbols.subtracting(removed)
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

            case .onDisconnet:
                subscribed = []
            }
        }
    }

    func subscribeMessages() async {
        for await message in await socket.messages {
            switch message {
            case let .data(data):
                onMessage(data)

            case let .text(string):
                print(string)
                if let data = string.data(using: .utf8) {
                    onMessage(data)
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

            case .subscribeStatus:
                guard let subscribeStatus = try? decoder.decode(TwelveDataSubscribeStatusEvent.self, from: json) else {
                    return
                }

                let success = subscribeStatus.success?.map(\.symbol) ?? []

                subscribed = subscribed.union(success)

                let failsSubscriptions = subscribeStatus.fails?.map(\.symbol) ?? []

                faild = faild.union(failsSubscriptions)

            case .heartbeat:
                break
            }

        } catch {
            print(error)
        }
    }

    func symbolsDidChange() {
        Task {
            do {
                try await invalidateSubscription()
            } catch {}
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
        }

        if needsUnSubsribe.isEmpty == false {
            let unsubscribeRequest = TwelveDataRequest.unsubscribe(needsUnSubsribe)

            let data = try encoder.encode(unsubscribeRequest)
            if let json = String(data: data, encoding: .utf8) {
                try await socket.send(json)
            }
        }
    }

    func invalidateConfiguration() {
        Task {
            await socket.update(configuration: .init(configuration))
        }
    }
}
