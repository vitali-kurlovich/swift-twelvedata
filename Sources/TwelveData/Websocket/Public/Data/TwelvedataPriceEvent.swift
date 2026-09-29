//
//  Created by Kurlovich Vitali on 9/29/26.
//

import Foundation

public struct TwelvedataPriceEvent: Equatable, Decodable, Sendable {
    public let symbol: String
    public let type: String
    public let currency: String?
    public let exchange: String?
    public let timestamp: Date
    public let price: Decimal
    public let day_volume: Decimal?
}
