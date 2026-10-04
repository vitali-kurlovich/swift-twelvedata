//
//  Created by Kurlovich Vitali on 10/4/26.
//

public struct TwelveDataForexPair: Equatable, Decodable, Sendable {
    public let symbol: String
    public let currency_group: String
    public let currency_base: String
    public let currency_quote: String
}

public struct TwelveDataForexPairsResponse: Equatable, Decodable, Sendable {
    public let count: Int
    public let data: [TwelveDataForexPair]
    public let status: String
}
