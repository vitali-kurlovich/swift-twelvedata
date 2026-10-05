//
//  Created by Kurlovich Vitali on 10/4/26.
//

/// Forex pair
///
/// More info avalible in [API Docs](https://twelvedata.com/docs/asset-catalogs/forex-pairs-list)
public nonisolated struct TwelveDataForexPair: Equatable, Decodable, Sendable {
    /// The ticker symbol of an instrument for which data is requested
    public let symbol: String
    /// Group to which currency pair belongs to, could be: Major, Minor, Exotic and Exotic-Cross
    public let currency_group: String
    /// Base currency name according to ISO 4217 standard
    public let currency_base: String
    /// Quote currency name according to ISO 4217 standard
    public let currency_quote: String
}

public typealias TwelveDataForexPairsResponse = TwelveDataPageResponse<TwelveDataForexPair>
