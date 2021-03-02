import HTTPClient
import Foundation

public enum Calls {
    public struct Post<Response: Decodable> {
        let path: String
        let body: AnyEncodable

        public init(
            path: String,
            body: Encodable
        ) {
            self.path = path
            self.body = AnyEncodable(body)
        }
    }

    public struct Get<Response: Decodable> {
        let path: String
        let query: [URLQueryItem]

        public init(
            path: String,
            query: [URLQueryItem] = []
        ) {
            self.path = path
            self.query = query
        }
    }
}


public struct Retrofit {
    private let components: URLComponents
    private let client: HTTPClient
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        baseURL: URL,
        client: HTTPClient,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) throws {
        guard
            let components = URLComponents(
                url: baseURL,
                resolvingAgainstBaseURL: false
            )
        else {
            throw URLError(.badURL)
        }

        self.client = client
        self.components = components
        self.encoder = encoder
        self.decoder = decoder
    }

    public func execute<Response: Decodable>(
        _ post: Calls.Post<Response>
    ) -> APICallPublisher<Response> {
        var request = HTTPRequest(components: components)
        request.path += "/" + post.path
        request.method = .post
        request.body = .encodableModel(encoder: encoder, value: post.body)

        return client
            .call(request: request)
            .decoded(as: Response.self, using: decoder)
    }

    public func execute<Response: Decodable>(
        _ get: Calls.Get<Response>
    ) -> APICallPublisher<Response> {
        var getComponents = components
        getComponents.queryItems = get.query

        var request = HTTPRequest(components: getComponents)
        request.path += "/" + get.path
        request.method = .get

        return client
            .call(request: request)
            .decoded(as: Response.self, using: decoder)
    }
}
