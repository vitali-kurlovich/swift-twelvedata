//
//  Created by Kurlovich Vitali on 10/4/26.
//

#if TwelveDataLogging
    import Logging

    private let logger: Logger = .init(label: String(describing: TwelveDataREST.self))
#endif

public extension TwelveDataREST {
    /**
     Forex pairs

     The forex pairs endpoint provides a comprehensive list of all available foreign exchange currency pairs. It returns an array of forex pairs, which is updated daily.
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

public extension TwelveDataREST {
    /**
     Latest price

     The latest price endpoint provides the latest market price for a specified financial instrument. It returns a single data point representing the current (or the most recently available) trading price.
     */
    func latestPrice(symbol _: String) async throws(TwelveDataRESTError) -> TwelveDataPriceResponse {
        do {
            return try await fetch(
                TwelveDataPriceResponse.self,
                for: configuration.forexPairsURL
            )
        } catch {
            #if TwelveDataLogging
                logger.error("Error at fetching latest price data:\(error.localizedDescription)")
            #endif

            throw error
        }
    }
}
