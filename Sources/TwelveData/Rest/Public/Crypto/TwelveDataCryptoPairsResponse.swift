//
//  Created by Kurlovich Vitali on 10/5/26.
//

/// Cryptocurrency pair
///
/// More info avalible in [API Docs](https://twelvedata.com/docs/asset-catalogs/cryptocurrencies-list)
public nonisolated struct TwelveDataCryptoPair: Equatable, Decodable, Sendable {
    /// Cryptocurrency pair codes with slash(/) delimiter
    public let symbol: String
    /// List of exchanges where the cryptocurrency is available
    public let available_exchanges: [String]
    /// Base currency of the cryptocurrency pair
    public let currency_base: String
    /// Quote currency of the cryptocurrency pair
    public let currency_quote: String
}

public typealias TwelveDataCryptoPairsResponse = TwelveDataPairsResponse<TwelveDataCryptoPair>
