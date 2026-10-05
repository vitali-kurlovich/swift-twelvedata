//
//  Created by Kurlovich Vitali on 9/29/26.
//

public enum TwelveDataWebsocketState: Equatable, Sendable {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case failed
}
