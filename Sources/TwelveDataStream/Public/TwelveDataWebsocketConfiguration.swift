//
//  Created by Kurlovich Vitali on 9/29/26.
//

import Foundation
import StreamWebSocket

private let baseURL = URL(string: "wss://ws.twelvedata.com/v1/quotes/price")!

public struct TwelveDataWebsocketConfiguration: Equatable, Sendable {
    public var baseUrl: URL
    public var apiKey: String

    public init(baseUrl: URL, apiKey: String) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
    }
}

public extension TwelveDataWebsocketConfiguration {
    init(apiKey: String) {
        self.init(baseUrl: baseURL, apiKey: apiKey)
    }
}

extension WebSocketConfiguration {
    init(_ configuration: TwelveDataWebsocketConfiguration) {
        self.init(url: configuration.baseUrl, headers: ["X-TD-APIKEY": configuration.apiKey])
    }
}
