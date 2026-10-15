//
//  Created by Kurlovich Vitali on 9/29/26.
//

import Foundation

enum TwelveDataEventStatus: String, Decodable, Sendable {
    case ok
    case warning
    case error

    case unknown
}

struct TwelveDataEventResponse: Equatable, Decodable, Sendable {
    enum Event: String, Decodable {
        case subscribeStatus = "subscribe-status"
        case unsubscribeStatus = "unsubscribe-status"
        case resetStatus = "reset-status"
        case price
        case heartbeat
        case connection
    }

    let event: Event
    let status: TwelveDataEventStatus?

    let success: [TwelveDataInstrument]?
    let fails: [TwelveDataInstrument]?
    let message: String?
}

extension TwelvedataEvent {
    static func decode(from data: Data) throws -> Self {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let response = try decoder.decode(TwelveDataEventResponse.self, from: data)
        switch response.event {
        case .subscribeStatus:
            return .subscribe(
                status: response.status ?? .unknown,
                success: response.success ?? [],
                fails: response.fails ?? []
            )
        case .unsubscribeStatus:
            return .unsubscribe(
                status: response.status ?? .unknown,
                success: response.success ?? [],
                fails: response.fails ?? []
            )
        case .resetStatus:
            return .reset(status: response.status ?? .unknown)
        case .price:
            let price = try decoder.decode(TwelvedataPriceEvent.self, from: data)
            return .price(price)
        case .heartbeat:
            return .heartbeat(status: response.status ?? .unknown)
        case .connection:
            return .connection(
                status: response.status ?? .unknown,
                message: response.message ?? ""
            )
        }
    }
}

enum TwelvedataEvent: Equatable, Sendable {
    case subscribe(status: TwelveDataEventStatus, success: [TwelveDataInstrument], fails: [TwelveDataInstrument])

    case unsubscribe(status: TwelveDataEventStatus, success: [TwelveDataInstrument], fails: [TwelveDataInstrument])

    case price(TwelvedataPriceEvent)

    case reset(status: TwelveDataEventStatus)

    case heartbeat(status: TwelveDataEventStatus)

    case connection(status: TwelveDataEventStatus, message: String)
}
