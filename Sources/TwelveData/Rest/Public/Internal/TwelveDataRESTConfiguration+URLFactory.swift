//
//  Created by Kurlovich Vitali on 10/4/26.
//

import Foundation

extension TwelveDataRESTConfiguration {
    func lastPriceURL(for symbol: String) -> URL {
        let queryItem = URLQueryItem(name: "symbol", value: symbol)

        return buildURL(.price, queryItem)
    }
}

extension TwelveDataRESTConfiguration {
    var forexPairsURL: URL {
        buildURL(.forexPairs)
    }
}
