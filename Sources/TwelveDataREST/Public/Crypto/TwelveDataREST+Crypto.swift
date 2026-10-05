//
//  Created by Kurlovich Vitali on 10/5/26.
//

#if TwelveDataRESTLogging
    import Logging

    private let logger: Logger = .init(label: String(describing: TwelveDataREST.self))
#endif

public extension TwelveDataREST {
    /**
     Cryptocurrency pairs

     The cryptocurrencies endpoint provides a daily updated list of all available cryptos. It returns an array containing detailed information about each cryptocurrency, including its symbol, name, and other relevant identifiers. This endpoint is useful for retrieving a comprehensive catalog of cryptocurrencies for applications that require up-to-date market listings or need to display available crypto assets to users.

     More info avalible in [API Docs](https://twelvedata.com/docs/asset-catalogs/cryptocurrencies-list)
     */
    func cryptoPairs() async throws(TwelveDataRESTError) -> TwelveDataCryptoPairsResponse {
        do {
            return try await fetch(
                TwelveDataCryptoPairsResponse.self,
                for: configuration.cryptoPairsURL
            )
        } catch {
            #if TwelveDataRESTLogging
                logger.error("Error at fetching crypto pairs data:\(error.localizedDescription)")
            #endif

            throw error
        }
    }

    /**
     Cryptocurrency pairs

     The cryptocurrencies endpoint provides a daily updated list of all available cryptos. It returns an array containing detailed information about each cryptocurrency, including its symbol, name, and other relevant identifiers. This endpoint is useful for retrieving a comprehensive catalog of cryptocurrencies for applications that require up-to-date market listings or need to display available crypto assets to users.

     More info avalible in [API Docs](https://twelvedata.com/docs/asset-catalogs/cryptocurrencies-list)
     */
    func cryptoPairs(page: Page) async throws(TwelveDataRESTError) -> TwelveDataCryptoPairsResponse {
        do {
            return try await fetch(
                TwelveDataCryptoPairsResponse.self,
                for: configuration.cryptoPairsURL(page: page)
            )
        } catch {
            #if TwelveDataRESTLogging
                logger.error("Error at fetching crypto pairs data:\(error.localizedDescription)")
            #endif

            throw error
        }
    }
}
