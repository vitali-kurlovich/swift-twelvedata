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
