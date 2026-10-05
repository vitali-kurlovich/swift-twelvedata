//
//  Created by Kurlovich Vitali on 10/5/26.
//

#if TwelveDataLogging
    import Logging

    private let logger: Logger = .init(label: String(describing: TwelveDataREST.self))
#endif

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
