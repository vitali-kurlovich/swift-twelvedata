//
//  Created by Kurlovich Vitali on 10/5/26.
//

#if TwelveDataRESTLogging
    import Logging

    private let logger: Logger = .init(label: String(describing: TwelveDataREST.self))
#endif

public extension TwelveDataREST {
    /**
     Stocks list

     The stocks endpoint provides a daily updated list of all available stock symbols. It returns an array containing the symbols, which can be used to identify and access specific stock data across various services. This endpoint is essential for users needing to retrieve the latest stock symbol information for further data requests or integration into financial applications.

     More info avalible in [API Docs](https://twelvedata.com/docs/asset-catalogs/stocks-list)
     */
    func stocks() async throws(TwelveDataRESTError) -> TwelveDataStocksResponse {
        do {
            return try await fetch(
                TwelveDataStocksResponse.self,
                for: configuration.stocksURL
            )
        } catch {
            #if TwelveDataRESTLogging
                logger.error("Error at fetching stocks list data:\(error.localizedDescription)")
            #endif

            throw error
        }
    }

    /**
     Stocks list

     The stocks endpoint provides a daily updated list of all available stock symbols. It returns an array containing the symbols, which can be used to identify and access specific stock data across various services. This endpoint is essential for users needing to retrieve the latest stock symbol information for further data requests or integration into financial applications.

     More info avalible in [API Docs](https://twelvedata.com/docs/asset-catalogs/stocks-list)
     */
    func stocks(page: Page) async throws(TwelveDataRESTError) -> TwelveDataStocksResponse {
        do {
            return try await fetch(
                TwelveDataStocksResponse.self,
                for: configuration.stocksURL(page: page)
            )
        } catch {
            #if TwelveDataRESTLogging
                logger.error("Error at fetching stocks list data:\(error.localizedDescription)")
            #endif

            throw error
        }
    }
}
