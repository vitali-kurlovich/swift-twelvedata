//
//  Created by Kurlovich Vitali on 10/4/26.
//

import Foundation

extension TwelveDataRESTConfiguration {
    nonisolated func lastPriceURL(for symbol: String) -> URL {
        let queryItem = URLQueryItem(name: "symbol", value: symbol)

        return buildURL(.price, queryItem)
    }
}

extension TwelveDataRESTConfiguration {
    nonisolated var forexPairsURL: URL {
        buildURL(.forexPairs)
    }

    nonisolated func forexPairsURL(page: Page) -> URL {
        buildURL(.forexPairs, page: page)
    }
}

extension TwelveDataRESTConfiguration {
    nonisolated var cryptoPairsURL: URL {
        buildURL(.cryptoPairs)
    }

    nonisolated func cryptoPairsURL(page: Page) -> URL {
        buildURL(.cryptoPairs, page: page)
    }
}

extension TwelveDataRESTConfiguration {
    nonisolated var stocksURL: URL {
        buildURL(.stocks)
    }

    nonisolated func stocksURL(page: Page) -> URL {
        buildURL(.stocks, page: page)
    }
}

extension TwelveDataRESTConfiguration {
    nonisolated var commoditiesURL: URL {
        buildURL(.commodities)
    }

    nonisolated func commoditiesURL(page: Page) -> URL {
        buildURL(.commodities, page: page)
    }
}
