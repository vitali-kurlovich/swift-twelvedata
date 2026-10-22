//
//  Created by Kurlovich Vitali on 10/15/26.
//

#if TwelveDataStreamLogging
    import Logging

    private let logger: Logger = .init(label: String(describing: SubscriptionsCoordinator.self))
#endif

actor SubscriptionsCoordinator {
    weak var socket: TwelveDataWebsocket?

    func setSocket(_ socket: TwelveDataWebsocket) {
        self.socket = socket
    }

    enum State {
        case idle
        case disconnected
        case waitingForResponse(TwelveDataRequest)
    }

    private(set) var subscriptions: Set<String> = []

    private(set) var activeSubscriptions: Set<String> = []
    private(set) var failedSubscriptions: Set<String> = []

    private(set) var state: State = .disconnected
}

extension SubscriptionsCoordinator {
    func connect() async throws {
        state = .idle
        try await invalidateSubscriptions()
    }

    func disconnect() {
        state = .disconnected
        activeSubscriptions.removeAll()
        failedSubscriptions.removeAll()
    }

    func subscribe(_ insert: Set<String>) async throws {
        subscriptions.formUnion(insert)
        try await invalidateSubscriptions()
    }

    func unsubscribe(_ remove: Set<String>) async throws {
        subscriptions.subtract(remove)
        try await invalidateSubscriptions()
    }
}

extension SubscriptionsCoordinator {
    func on(event: TwelvedataEvent) async throws {
        guard let socket else { return }

        switch event {
        case let .subscribe(
            status: status,
            success: success,
            fails: fails
        ):
            let subsribed = success.map {
                $0.symbol
            }

            activeSubscriptions.formUnion(subsribed)

            let fails = fails.map { $0.symbol }

            failedSubscriptions.formUnion(fails)

            switch state {
            case .idle, .disconnected:
                assertionFailure()
            case let .waitingForResponse(request):
                assert(request.action == .subscribe)
                state = .idle
                try await invalidateSubscriptions()
            }

        case let .unsubscribe(
            status: status,
            success: success,
            fails: _
        ):
            let unsubsribed = success.map {
                $0.symbol
            }

            activeSubscriptions.subtract(unsubsribed)

            switch state {
            case .idle, .disconnected:
                assertionFailure()
            case let .waitingForResponse(request):
                assert(request.action == .unsubscribe)
                state = .idle
                try await invalidateSubscriptions()
            }

        case let .price(price):
            await socket.recieve(price: price)

        case let .reset(status: status):
            switch state {
            case .idle, .disconnected:
                assertionFailure()
            case let .waitingForResponse(request):
                assert(request.action == .reset)
                state = .idle
                activeSubscriptions.removeAll()
                failedSubscriptions.removeAll()

                try await invalidateSubscriptions()
            }

        case .heartbeat:
            break

        case let .connection(status: status, message: message):
            #if TwelveDataStreamLogging
                switch status {
                case .ok:
                    logger.info("\(message)")
                case .warning:
                    logger.warning("\(message)")
                case .error:
                    logger.error("\(message)")
                case .unknown:
                    break
                }

            #endif
        }
    }
}

private extension SubscriptionsCoordinator {
    func invalidateSubscriptions() async throws {
        guard let socket else { return }

        switch state {
        case .idle:
            break
        case .waitingForResponse, .disconnected:
            return
        }

        if subscriptions.isEmpty {
            let request = TwelveDataRequest.reset()

            state = .waitingForResponse(request)

            try await socket.send(request)

            return
        }

        let subscriptions = subscriptions.subtracting(failedSubscriptions)

        let remove = activeSubscriptions.subtracting(subscriptions)

        if remove.isEmpty == false {
            let request = TwelveDataRequest.unsubscribe(remove)
            state = .waitingForResponse(request)
            try await socket.send(request)
            return
        }

        let insert = subscriptions.subtracting(activeSubscriptions)
        if insert.isEmpty == false {
            let request = TwelveDataRequest.subscribe(insert)
            state = .waitingForResponse(request)
            try await socket.send(request)
            return
        }
    }
}
