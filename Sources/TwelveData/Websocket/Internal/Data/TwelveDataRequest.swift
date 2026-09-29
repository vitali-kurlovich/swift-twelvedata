//
//  Created by Kurlovich Vitali on 9/26/26.
//

import Foundation

struct TwelveDataRequest: Encodable, Sendable {
    enum Action: String, Encodable, Sendable {
        case subscribe
        case unsubscribe
        case heartbeat
        case reset
    }

    struct Params: Encodable, Sendable {
        let symbols: String
    }

    let action: Action
    let params: Params?
}

extension TwelveDataRequest {
    static func reset() -> Self {
        .init(action: .reset, params: nil)
    }

    static func heartbeat() -> Self {
        .init(action: .heartbeat, params: nil)
    }

    static func subscribe<S: Sequence>(_ symbols: S) -> Self where S.Element == String {
        let symbols = symbols.joined(separator: ",")
        return .init(action: .subscribe, params: .init(symbols: symbols))
    }

    static func unsubscribe<S: Sequence>(_ symbols: S) -> Self where S.Element == String {
        let symbols = symbols.joined(separator: ",")
        return .init(action: .unsubscribe, params: .init(symbols: symbols))
    }
}
