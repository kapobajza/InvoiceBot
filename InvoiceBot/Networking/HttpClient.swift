import Combine
import Foundation

protocol RequestWithoutBody: Encodable {}

struct AnyDecodable: Decodable {}

struct EmptyRequest: RequestWithoutBody {}

struct HttpRequestBody {
    let encodable: Encodable?
    let data: Data?

    init() {
        encodable = nil
        data = nil
    }

    init(encodable: Encodable) {
        self.encodable = encodable
        data = nil
    }

    init(data: Data) {
        encodable = nil
        self.data = data
    }
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol HttpClientProtocol {
    func get<TResponse: Decodable>(route: String) -> AnyPublisher<TResponse?, Error>
    func post<TResponse: Decodable>(
        route: String,
        body: HttpRequestBody
    ) -> AnyPublisher<TResponse?, Error>
    func put<TResponse: Decodable>(
        route: String,
        body: HttpRequestBody
    ) -> AnyPublisher<TResponse?, Error>
    func delete<TResponse: Decodable>(route: String) -> AnyPublisher<TResponse?, Error>
}

public class HttpClient: HttpClientProtocol {
    private let baseUrl: String
    private let storage: StorageProtocol
    private let jsonEncoder = JSONEncoder()

    private func makeRequest<TResponse: Decodable>(
        route: String,
        method: HttpMethod,
        body: HttpRequestBody?
    ) -> AnyPublisher<TResponse?, Error> {
        return Future { promise in
            Task {
                do {
                    var request = URLRequest(url: URL(string: "\(self.baseUrl)\(route)")!)
                    request.httpMethod = method.rawValue

                    if let body = body {
                        var finalBody: Data? = nil

                        if let encodableBody = body.encodable {
                            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            finalBody = try self.jsonEncoder.encode(encodableBody)
                        } else if let dataBody = body.data {
                            finalBody = dataBody
                        }

                        request.httpBody = finalBody
                    }

                    let accessToken: String? = self.storage.get(key: .accessToken)

                    if let accessToken = accessToken, !accessToken.isEmpty {
                        // Set headers, including authorization header with the access token
                        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                    }

                    let (data, response) = try await URLSession.shared.data(for: request)

                    if let httpResponse = response as? HTTPURLResponse,
                       (400 ... 599).contains(httpResponse.statusCode)
                    {
                        var userInfo: [String: Any]? = nil

                        if let jsonString = String(data: data, encoding: .utf8) {
                            userInfo = [NSLocalizedDescriptionKey: jsonString]
                        }

                        return promise(
                            .failure(
                                NSError(
                                    domain: "HttpClient - makeRequest",
                                    code: httpResponse.statusCode,
                                    userInfo: userInfo
                                )
                            )
                        )
                    }

                    // TResponse is a generic that conforms to Decodable
                    var json: TResponse? = nil

                    if !data.isEmpty {
                        let decoder = JSONDecoder()
                        json = try decoder.decode(TResponse.self, from: data)
                    }

                    return promise(.success(json))
                } catch {
                    return promise(
                        .failure(
                            NSError(
                                domain: "HttpClient - makeRequest", code: 0,
                                userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]
                            )
                        )
                    )
                }
            }
        }.eraseToAnyPublisher()
    }

    init(
        baseUrl: String,
        storage: StorageProtocol
    ) {
        self.baseUrl = baseUrl
        self.storage = storage
    }

    func get<TResponse: Decodable>(route: String) -> AnyPublisher<TResponse?, Error> {
        return makeRequest(route: route, method: .get, body: HttpRequestBody())
    }

    func post<TResponse: Decodable>(
        route: String,
        body: HttpRequestBody
    ) -> AnyPublisher<TResponse?, Error> {
        return makeRequest(route: route, method: .post, body: body)
    }

    func put<TResponse: Decodable>(
        route: String,
        body: HttpRequestBody
    ) -> AnyPublisher<TResponse?, Error> {
        return makeRequest(route: route, method: .put, body: body)
    }

    func delete<TResponse: Decodable>(route: String) -> AnyPublisher<TResponse?, Error> {
        return makeRequest(route: route, method: .delete, body: HttpRequestBody())
    }
}

class HttpClientMock: HttpClientProtocol {
    var getResponse: Any?
    var postResponse: Any?
    var putResponse: Any?
    var deleteResponse: Any?

    func get<TResponse: Decodable>(route: String) -> AnyPublisher<TResponse?, Error> {
        return Future { promise in
            if let response = self.getResponse as? TResponse {
                promise(.success(response))
            } else {
                promise(.failure(NSError(domain: "HttpClientMock get", code: 0, userInfo: nil)))
            }
        }.eraseToAnyPublisher()
    }

    func post<TResponse: Decodable>(route: String, body: HttpRequestBody) -> AnyPublisher<
        TResponse, Error
    > {
        return Future { promise in
            if let response = self.postResponse as? TResponse {
                promise(.success(response))
            } else {
                promise(.failure(NSError(domain: "HttpClientMock post", code: 0, userInfo: nil)))
            }
        }.eraseToAnyPublisher()
    }

    func put<TResponse: Decodable>(route: String, body: HttpRequestBody) -> AnyPublisher<
        TResponse, Error
    > {
        return Future { promise in
            if let response = self.putResponse as? TResponse {
                promise(.success(response))
            } else {
                promise(.failure(NSError(domain: "HttpClientMock put", code: 0, userInfo: nil)))
            }
        }.eraseToAnyPublisher()
    }

    func delete<TResponse: Decodable>(route: String) -> AnyPublisher<TResponse?, Error> {
        return Future { promise in
            if let response = self.deleteResponse as? TResponse {
                promise(.success(response))
            } else {
                promise(.failure(NSError(domain: "HttpClientMock delete", code: 0, userInfo: nil)))
            }
        }.eraseToAnyPublisher()
    }
}
