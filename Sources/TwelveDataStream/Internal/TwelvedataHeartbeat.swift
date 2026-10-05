//
//  Created by Kurlovich Vitali on 9/28/26.
//

import Foundation
import StreamWebSocket

struct TwelvedataHeartbeat: WebSocketPing {
    func ping(_ socket: WebSocket) {
        Task {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(TwelveDataRequest.heartbeat())

                guard let json = String(data: data, encoding: .utf8) else {
                    return
                }
                try await socket.send(json)
            } catch {
                print(error)
            }
        }
    }
}
