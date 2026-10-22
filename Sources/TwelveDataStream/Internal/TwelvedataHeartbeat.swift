//
//  Created by Kurlovich Vitali on 9/28/26.
//

import Foundation
import StreamWebSocket

struct TwelvedataHeartbeat: WebSocketPing {
    static let heartbeatJson: String = {
        let data = try! JSONEncoder().encode(TwelveDataRequest.heartbeat())
        return String(decoding: data, as: UTF8.self)
    }()

    func ping(_ socket: WebSocket) async throws {
        try await socket.send(Self.heartbeatJson)
    }
}
