//
//  Created by Kurlovich Vitali on 10/5/26.
//

/// Stocks
///
/// More info avalible in [API Docs](https://twelvedata.com/docs/asset-catalogs/stocks-list)
public nonisolated struct TwelveDataStock: Equatable, Decodable, Sendable {
    /// Instrument symbol (ticker)
    public let symbol: String
    /// Full name of instrument
    public let name: String
    /// Currency of the instrument according to the ISO 4217 standard
    public let currency: String

    /// Exchange where instrument is traded
    public let exchange: String

    ///  Market identifier code (MIC) under ISO 10383 standard
    public let mic_code: String

    /// Country where exchange is located
    public let country: String

    ///  Common issue type
    public let type: String

    /// Financial instrument global identifier (FIGI)
    public let figi_code: String

    /// Classification of Financial Instruments (CFI)
    public let cfi_code: String

    /// International securities identification number (ISIN), available by individual request to support
    public let isin: String

    /// A unique nine-character alphanumeric code used to identify financial securities, ensuring accurate data retrieval for the specified asset
    public let cusip: String
}

public typealias TwelveDataStocksResponse = TwelveDataPageResponse<TwelveDataStock>
