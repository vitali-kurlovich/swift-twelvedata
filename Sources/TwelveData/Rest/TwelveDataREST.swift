//
//  Created by Kurlovich Vitali on 10/4/26.
//

import Foundation

public nonisolated struct TwelveDataREST: Sendable {
    public typealias Configuration = TwelveDataRESTConfiguration

    public init(configuration: Configuration, sessionConfiguration: URLSessionConfiguration = .default) {
        self.sessionConfiguration = sessionConfiguration
        self.configuration = configuration
    }

    public let sessionConfiguration: URLSessionConfiguration
    public var configuration: Configuration
}

public extension TwelveDataREST {
    nonisolated init(apiKey: String, sessionConfiguration: URLSessionConfiguration = .default) {
        let configuration = Configuration(apiKey: apiKey)
        self.init(configuration: configuration, sessionConfiguration: sessionConfiguration)
    }

    nonisolated init(
        baseUrl: URL,
        apiKey: String,
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        let configuration = Configuration(baseUrl: baseUrl, apiKey: apiKey)
        self.init(configuration: configuration, sessionConfiguration: sessionConfiguration)
    }
}
