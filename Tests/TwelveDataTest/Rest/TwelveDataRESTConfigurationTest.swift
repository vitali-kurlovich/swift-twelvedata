//
//  Created by Kurlovich Vitali on 10/4/26.
//

import Foundation
import Testing
@testable import TwelveData

private let testBaseURL = URL(string: "https://test.dev")!
private let testApiKey = "test_api"

struct TwelveDataRESTConfigurationTest {
    var configuration: TwelveDataRESTConfiguration {
        TwelveDataRESTConfiguration(baseUrl: testBaseURL, apiKey: testApiKey)
    }

    @Test
    func lastPriceURL() {
        #expect(
            configuration
                .lastPriceURL(for: "AAPL") == URL(
                    string: "\(testBaseURL)/price?symbol=AAPL&apikey=\(testApiKey)"
                )
        )
    }

    @Test
    func forexPairsURL() {
        #expect(
            configuration.forexPairsURL == URL(string: "\(testBaseURL)/forex_pairs?apikey=\(testApiKey)")
        )
    }
}
