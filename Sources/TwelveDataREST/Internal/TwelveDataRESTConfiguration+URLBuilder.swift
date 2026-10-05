//
//  Created by Kurlovich Vitali on 10/4/26.
//

import Foundation

extension TwelveDataRESTConfiguration {
    nonisolated func buildURL(_ command: Command, _ queryItems: [URLQueryItem] = []) -> URL {
        var queryItems = queryItems

        let apiKeyQueryItem = URLQueryItem(name: "apikey", value: apiKey)
        queryItems.append(apiKeyQueryItem)

        return baseUrl.appending(component: command.rawValue).appending(queryItems: queryItems)
    }

    nonisolated func buildURL(_ command: Command, _ queryItem: URLQueryItem) -> URL {
        buildURL(command, [queryItem])
    }
}

extension TwelveDataRESTConfiguration {
    typealias Page = TwelveDataPageConfiguration

    nonisolated func buildURL(_ command: Command, page: Page, _ queryItems: [URLQueryItem] = []) -> URL {
        var queryItems = queryItems
        queryItems.append(contentsOf: page.queryItems)
        return buildURL(command, queryItems)
    }

    nonisolated func buildURL(_ command: Command, page: Page, _ queryItem: URLQueryItem) -> URL {
        var queryItems = page.queryItems
        queryItems.append(queryItem)
        return buildURL(command, queryItems)
    }
}

extension TwelveDataPageConfiguration {
    nonisolated var queryItems: [URLQueryItem] {
        let page = URLQueryItem(name: "page", value: .init(self.page))
        let outputsize = URLQueryItem(name: "outputsize", value: .init(size))
        return [page, outputsize]
    }
}
