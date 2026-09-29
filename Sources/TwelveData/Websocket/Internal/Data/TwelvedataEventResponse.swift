//
//  Created by Kurlovich Vitali on 9/29/26.
//

import Foundation

struct TwelvedataEventResponse: Equatable, Decodable, Sendable {
    enum Event: String, Decodable {
        case subscribeStatus = "subscribe-status"
        case price
        case heartbeat
    }

    let event: Event
    // let status: String?

    /*
     "symbol":"RY","exchange":"TSX",
           "country":"Canada",
           "type":"Common Stock"

     */
}

enum TwelvedataEvent: Equatable, Sendable {
    case subscribeStatus(TwelveDataSubscribeStatusEvent)
    case price(TwelvedataPriceEvent)
}

/*

 "symbol":"BTC/USD","exchange":"FOREX",
       "country":"",
       "type":"Physical Currency"

 */

/*

 "event": "price",
   "symbol": "AAPL",
   "currency": "USD",
   "exchange": "NASDAQ",
   "type": "Common Stock",
   "timestamp": 1592249566,
   "price": 342.0157,
   "day_volume": 27631112

 */
