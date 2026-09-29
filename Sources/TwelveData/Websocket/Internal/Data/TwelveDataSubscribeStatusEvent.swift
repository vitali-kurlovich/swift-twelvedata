//
//  Created by Kurlovich Vitali on 9/29/26.
//

struct TwelveDataSubscribeStatusEvent: Equatable, Decodable, Sendable {
    let success: [TwelveDataInstrument]?
    let fails: [TwelveDataInstrument]?
}
