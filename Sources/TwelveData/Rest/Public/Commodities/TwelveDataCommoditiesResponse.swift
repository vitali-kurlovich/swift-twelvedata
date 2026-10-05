//
//  Created by Kurlovich Vitali on 10/5/26.
//

/// Commodities list
///
/// More info avalible in [API Docs](https://twelvedata.com/docs/asset-catalogs/commodities-list)
public nonisolated struct TwelveDataCommodity: Equatable, Decodable, Sendable {
    /// Currency pair according to ISO 4217 standard codes with slash(/) delimiter
    public let symbol: String
    /// Full name of the instrument
    public let name: String
    /// Category of commodity
    public let category: String
    /// Short description of the commodity
    public let description: String
}

public typealias TwelveDataCommoditiesResponse = TwelveDataPageResponse<TwelveDataCommodity>
