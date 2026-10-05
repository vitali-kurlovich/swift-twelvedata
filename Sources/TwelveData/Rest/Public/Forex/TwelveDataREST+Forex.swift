//
//  Created by Kurlovich Vitali on 10/5/26.
//

#if TwelveDataLogging
    import Logging

    private let logger: Logger = .init(label: String(describing: TwelveDataREST.self))
#endif

public extension TwelveDataREST {
    /**
     Forex pairs

     The forex pairs endpoint provides a comprehensive list of all available foreign exchange currency pairs. It returns an array of forex pairs, which is updated daily.

     More info avalible in [API Docs](https://twelvedata.com/docs/asset-catalogs/forex-pairs-list)
     */
    func forexPairs() async throws(TwelveDataRESTError) -> TwelveDataForexPairsResponse {
        do {
            return try await fetch(
                TwelveDataForexPairsResponse.self,
                for: configuration.forexPairsURL
            )
        } catch {
            #if TwelveDataLogging
                logger.error("Error at fetching forex pairs data:\(error.localizedDescription)")
            #endif

            throw error
        }
    }
}
