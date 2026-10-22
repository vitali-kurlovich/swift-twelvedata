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
    }

    deinit {
        setupTask?.cancel()
        socketStateChangeTask?.cancel()
        messagesTask?.cancel()
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

    private var setupTask: Task<Void, Never>?
    private var socketStateChangeTask: Task<Void, Never>?
    private var messagesTask: Task<Void, Never>?

    /// Connection intent: `true` while there are subscriptions to serve.
    private var wantsConnection = false

    private let coordinator = SubscriptionsCoordinator()
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
        let insert = Set(insert)
        try await updateSubscriptions { try await $0.subscribe(insert) }
    }

    func unsubscribe<S: Sequence>(symbols removed: S) async throws where S.Element == String {
        let removed = Set(removed)
        try await updateSubscriptions { try await $0.unsubscribe(removed) }
    }
}

extension TwelveDataWebsocket {
    func recieve(price: TwelvedataPriceEvent) {
        priceEventsContinuation.yield(price)
    }

    func send(_ request: TwelveDataRequest) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]

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
    /// Wires the coordinator and starts observing the socket. Runs once, and always
    /// completes before the first `socket.connect()`, so no state change is missed.
    func setUpIfNeeds() async {
        if setupTask == nil {
            setupTask = Task { [weak self] in
                await self?.setUp()
            }
        }
        await setupTask?.value
    }

    func setUp() async {
        await coordinator.setSocket(self)

        let states = await socket.states
        let messages = await socket.messages

        socketStateChangeTask = Task { [weak self] in
            for await state in states {
                await self?.on(state: state)
            }
        }

        messagesTask = Task { [weak self] in
            for await message in messages {
                await self?.on(message: message)
            }
        }
    }

    func updateSubscriptions(_ update: (SubscriptionsCoordinator) async throws -> Void) async throws {
        await setUpIfNeeds()

        do {
            try await update(coordinator)
        } catch {
            await invalidateConnection()
            throw error
        }
        await invalidateConnection()
    }

    /// Connects while there are subscriptions and disconnects when there are none.
    /// Loops because `subscriptions` may change while `connect`/`disconnect` is awaited.
    func invalidateConnection() async {
        while true {
            let needsConnection = await coordinator.subscriptions.isEmpty == false
            guard needsConnection != wantsConnection else { return }
            wantsConnection = needsConnection

            if needsConnection {
                await setUpIfNeeds()
                await socket.connect()
            } else {
                await socket.disconnect()
            }
        }
    }

    func on(state: WebSocket.State) async {
        switch state {
        case .disconnected:
            #if TwelveDataStreamLogging
                logger.info("Disconnect from server")
            #endif
            await coordinator.disconnect()

        case .connecting:
            #if TwelveDataStreamLogging
                logger.info("Connecting to server")
            #endif

        case .connected:
            #if TwelveDataStreamLogging
                logger.info("Connected to server")
            #endif
            do {
                try await coordinator.connect()
            } catch {
                #if TwelveDataStreamLogging
                    logger.error("\(error)")
                #endif
            }

        case let .reconnecting(attempt: attempt, delay: delay):
            // The socket always reports `.disconnected` before `.reconnecting`.
            #if TwelveDataStreamLogging
                logger.info("Reconnecting to server - attempt:\(attempt), delay:\(delay)")
            #endif

        case let .failed(error):
            #if TwelveDataStreamLogging
                logger.error("\(error)")
            #endif
            // The socket gave up, so the next subscribe or configuration update reconnects.
            wantsConnection = false
            await coordinator.disconnect()
        }
    }

    func on(message: WebSocketMessage) async {
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
            // Recovers from `.failed`, e.g. after an invalid API key was replaced.
            await invalidateConnection()
        }
        #if TwelveDataStreamLogging
            logger.debug("Update configuration")
        #endif
    }
}
