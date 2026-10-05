//
//  Created by Kurlovich Vitali on 10/5/26.
//

public nonisolated struct TwelveDataPageConfiguration: Equatable, Sendable {
    /// Page number of the results to fetch
    let page: Int
    /// Determines the number of data points returned in the output. If not specified, all available records are returned
    let size: Int

    public init(page: Int, size: Int) {
        self.page = page
        self.size = size
    }
}
