//
//  Created by Kurlovich Vitali on 10/4/26.
//

import Foundation

#if TwelveDataLogging
    import Logging

    private let logger: Logger = .init(label: String(describing: TwelveDataREST.self))
#endif

extension TwelveDataREST {
    func fetch<T: Decodable>(_: T.Type, for url: URL) async throws(TwelveDataRESTError) -> T {
        do {
            let data = try await data(url: url)

            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)

        } catch let error as TwelveDataRESTError {
            throw error
        } catch {
            let jsonError = TwelveDataRESTJSONDecodicgError(
                localizedDescription: error.localizedDescription
            )

            throw TwelveDataRESTError.responseDecodingError(jsonError)
        }
    }
}

private extension TwelveDataREST {
    func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    func data(url: URL) async throws(TwelveDataRESTError) -> Data {
        do {
            let request = request(for: url)
            let session = URLSession(configuration: sessionConfiguration)

            #if TwelveDataLogging
                logger.debug("Send request:\(request.debugDescription)")
            #endif

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw TwelveDataRESTError.unknown
            }

            let code = httpResponse.statusCode

            if (200 ... 299).contains(code) {
                return data
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TwelveDataRESTErrorResponse.self, from: data)

                switch response.code {
                case 400:
                    throw TwelveDataRESTError.badRequest(response)
                case 401:
                    throw TwelveDataRESTError.unauthor­ized(response)
                case 403:
                    throw TwelveDataRESTError.forbidden(response)
                case 404:
                    throw TwelveDataRESTError.notFound(response)
                case 414:
                    throw TwelveDataRESTError.parameterTooLong(response)
                case 429:
                    throw TwelveDataRESTError.tooManyRequests(response)
                case 500:
                    throw TwelveDataRESTError.internalServerError(response)
                default:
                    throw TwelveDataRESTError.unknownServerError(response)
                }

            } catch let error as TwelveDataRESTError {
                throw error
            } catch {
                let jsonError = TwelveDataRESTJSONDecodicgError(
                    localizedDescription: error.localizedDescription
                )

                throw TwelveDataRESTError.responseDecodingError(jsonError)
            }

        } catch let error as TwelveDataRESTError {
            throw error
        } catch {
            let urlSessionError = TwelveDataRESTURLSessionError(
                localizedDescription: error.localizedDescription
            )

            throw .urlSessionError(urlSessionError)
        }
    }
}
