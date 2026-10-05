//
//  Created by Kurlovich Vitali on 10/4/26.
//

import Foundation

private let baseURL = URL(string: "https://api.twelvedata.com")!

public struct TwelveDataRESTConfiguration: Equatable, Sendable {
    public var baseUrl: URL
    public var apiKey: String

    public init(baseUrl: URL, apiKey: String) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
    }
}

public extension TwelveDataRESTConfiguration {
    init(apiKey: String) {
        self.init(baseUrl: baseURL, apiKey: apiKey)
    }
}
