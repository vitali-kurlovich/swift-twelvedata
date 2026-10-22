//
//  Created by Kurlovich Vitali on 9/28/26.
//

import Foundation
import StreamWebSocket

struct TwelvedataHeartbeat: WebSocketPing {
    static let heartbeatJson = """
    {"action": "heartbeat"}
    """

    func ping(_ socket: WebSocket) async throws {
        try await socket.send(Self.heartbeatJson)
    }
}
