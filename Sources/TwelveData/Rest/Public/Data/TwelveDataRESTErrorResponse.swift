//
//  Created by Kurlovich Vitali on 10/4/26.
//

public nonisolated struct TwelveDataRESTErrorResponse: Equatable, Decodable, Sendable {
    public let code: Int
    public let message: String
}
