//
//  Created by Kurlovich Vitali on 10/5/26.
//

nonisolated enum Command: String, Equatable, Sendable {
    case price
    case forexPairs = "forex_pairs"
    case cryptoPairs = "cryptocurrencies"
    case stocks = "stocks-list"
    case commodities
}
