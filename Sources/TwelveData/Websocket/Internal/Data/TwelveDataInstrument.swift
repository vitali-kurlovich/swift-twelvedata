//
//  Created by Kurlovich Vitali on 9/29/26.
//

struct TwelveDataInstrument: Equatable, Decodable, Sendable {
    let symbol: String
    let exchange: String
    let type: String
    let country: String?
}
