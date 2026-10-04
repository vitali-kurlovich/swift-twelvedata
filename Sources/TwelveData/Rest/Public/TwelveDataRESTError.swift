//
//  Created by Kurlovich Vitali on 10/4/26.
//

public enum TwelveDataRESTError: Error, Equatable, Sendable {
    /**

     Invalid or incorrect parameter(s) provided.

     - Code: 400 Bad Request

     Check the `message`  in the response for details. Refer to the API Documenta­tion to correct the input.

     */
    case badRequest(TwelveDataRESTErrorResponse)

    /**

     Invalid or incorrect API key.

     - Code: 401 Unauthor­ized

     Verify your API key is correct. Sign up for a key [here](https://twelvedata.com/account/api-keys).

     */
    case unauthor­ized(TwelveDataRESTErrorResponse)

    /**

     API key lacks permissions for the requested resource (upgrade required).

     - Code: 403 Forbidden

     Upgrade your plan [here](https://twelvedata.com/pricing).

     */
    case forbidden(TwelveDataRESTErrorResponse)

    /**

     Requested data could not be found.

     - Code: 404 Not Found

     Adjust parameters to be less strict as they may be too restrictive.

     */
    case notFound(TwelveDataRESTErrorResponse)

    /**

     Input parameter array exceeds the allowed length.

     - Code: 414 Parameter Too Long

     Follow the `message` guidance to adjust the parameter length.

     */
    case parameterTooLong(TwelveDataRESTErrorResponse)

    /**

     API request limit reached for your key.

     - Code: 429 Too Many Requests

     Wait briefly or upgrade your plan [here](https://twelvedata.com/pricing).

     */
    case tooManyRequests(TwelveDataRESTErrorResponse)

    /**

     Server-side issue occurred; retry later.

     - Code: 500 Internal Server Error

     Contact support [here](https://twelvedata.com/contact) for assistance.

     */
    case internalServerError(TwelveDataRESTErrorResponse)

    /// Error at sending request
    case urlSessionError(TwelveDataRESTURLSessionError)

    /// Server return unknown error code
    case unknownServerError(TwelveDataRESTErrorResponse)

    /// Error at decoding json
    case responseDecodingError(TwelveDataRESTJSONDecodicgError)
    case unknown
}

public struct TwelveDataRESTURLSessionError: Error, Equatable, Sendable {
    public let localizedDescription: String
}

public struct TwelveDataRESTJSONDecodicgError: Error, Equatable, Sendable {
    public let localizedDescription: String
}
