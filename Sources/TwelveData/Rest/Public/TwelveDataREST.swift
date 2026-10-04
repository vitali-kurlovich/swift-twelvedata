//
//  Created by Kurlovich Vitali on 10/4/26.
//

import Foundation

#if TwelveDataLogging
    import Logging

    private let logger: Logger = .init(label: String(describing: TwelveDataREST.self))
#endif

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
        #if TwelveDataLogging
            logger.debug("Update API key")
        #endif
        configuration.apiKey = apiKey
    }

    func update(baseUrl: URL) {
        #if TwelveDataLogging
            logger.debug("Update baseUrl")
        #endif

        configuration.baseUrl = baseUrl
    }

    func update(configuration: Configuration) {
        #if TwelveDataLogging
            logger.debug("Update configuration")
        #endif

        self.configuration = configuration
    }
}
