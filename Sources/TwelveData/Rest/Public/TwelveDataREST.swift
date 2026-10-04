//
//  Created by Kurlovich Vitali on 10/4/26.
//

import Foundation

public actor TwelveDataREST {
    public typealias Configuration = TwelveDataRESTConfiguration

    public init(configuration: Configuration, sessionConfiguration: URLSessionConfiguration = .default) {
        self.sessionConfiguration = sessionConfiguration
        self.configuration = configuration
    }

    let sessionConfiguration: URLSessionConfiguration
    public var configuration: Configuration
}

public extension TwelveDataREST {
    init(apiKey: String, sessionConfiguration: URLSessionConfiguration = .default) {
        let configuration = Configuration(apiKey: apiKey)
        self.init(configuration: configuration, sessionConfiguration: sessionConfiguration)
    }

    init(
        baseUrl: URL,
        apiKey: String,
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        let configuration = Configuration(baseUrl: baseUrl, apiKey: apiKey)
        self.init(configuration: configuration, sessionConfiguration: sessionConfiguration)
    }
}

public extension TwelveDataREST {
    func update(apiKey: String) {
        configuration.apiKey = apiKey
    }

    func update(baseUrl: URL) {
        configuration.baseUrl = baseUrl
    }

    func update(configuration: Configuration) {
        self.configuration = configuration
    }
}
