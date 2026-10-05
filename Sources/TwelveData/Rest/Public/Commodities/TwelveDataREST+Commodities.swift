//
//  Created by Kurlovich Vitali on 10/5/26.
//

#if TwelveDataLogging
    import Logging

    private let logger: Logger = .init(label: String(describing: TwelveDataREST.self))
#endif

public extension TwelveDataREST {
    /**
     Commodities list

     The commodities endpoint provides a daily updated list of available commodity pairs, across precious metals, livestock, softs, grains, etc.

     More info avalible in [API Docs](https://twelvedata.com/docs/asset-catalogs/commodities-list)
     */
    func commodities() async throws(TwelveDataRESTError) -> TwelveDataCommoditiesResponse {
        do {
            return try await fetch(
                TwelveDataCommoditiesResponse.self,
                for: configuration.commoditiesURL
            )
        } catch {
            #if TwelveDataLogging
                logger.error("Error at fetching commodities list data:\(error.localizedDescription)")
            #endif

            throw error
        }
    }

    /**
     Commodities list

     The commodities endpoint provides a daily updated list of available commodity pairs, across precious metals, livestock, softs, grains, etc.

     More info avalible in [API Docs](https://twelvedata.com/docs/asset-catalogs/commodities-list)
     */
    func commodities(page: Page) async throws(TwelveDataRESTError) -> TwelveDataCommoditiesResponse {
        do {
            return try await fetch(
                TwelveDataCommoditiesResponse.self,
                for: configuration.commoditiesURL(page: page)
            )
        } catch {
            #if TwelveDataLogging
                logger.error("Error at fetching commodities list data:\(error.localizedDescription)")
            #endif

            throw error
        }
    }
}
