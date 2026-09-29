//
//  Created by Kurlovich Vitali on 9/29/26.
//

import StreamWebSocket

extension TwelveDataWebsocket.State {
    init(_ state: WebSocket.State) {
        switch state {
        case .disconnected:
            self = .disconnected
        case .connecting:
            self = .connecting
        case .connected:
            self = .connected
        case .reconnecting:
            self = .reconnecting
        case .failed:
            self = .failed
        }
    }
}
