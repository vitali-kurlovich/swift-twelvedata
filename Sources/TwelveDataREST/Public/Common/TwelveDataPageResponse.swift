//
//  Created by Kurlovich Vitali on 10/5/26.
//

public nonisolated struct TwelveDataPageResponse<D: Equatable & Decodable & Sendable>: Equatable, Decodable, Sendable {
    public let count: Int
    public let data: [D]
    public let status: String
}
