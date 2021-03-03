import HTTPClient
import Foundation
import Combine

public struct Retrofit {
    private let components: URLComponents
    private let responder: HTTPResponder
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public static func make(
        baseURL: URL,
        responder: HTTPResponder = .fromURLSession(.shared),
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) throws -> Self {
        guard
            let components = URLComponents(
                url: baseURL,
                resolvingAgainstBaseURL: false
            )
        else {
            throw URLError(.badURL)
        }

        return .init(
            components: components,
            responder: responder,
            encoder: encoder,
            decoder: decoder
        )
    }

    private init(
        components: URLComponents,
        responder: HTTPResponder,
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) {
        self.responder = responder
        self.components = components
        self.encoder = encoder
        self.decoder = decoder
    }

    public func chaining(
        middlewares: [HTTPMiddleware]
    ) -> Self {
        .init(
            components: components,
            responder: .chaining(responder, middlewares: middlewares),
            encoder: encoder,
            decoder: decoder
        )
    }

    public func execute<Response: Decodable>(
        _ post: Calls.Post<Response>
    ) -> APICallPublisher<Response> {
        var request = HTTPRequest(components: components)
        request.path += "/" + post.path
        request.method = .post

        let bodyResult = Result<HTTPBody, Error> {
            try HTTPBody.json(
                encoder: encoder,
                value: post.body
            )
        }

        switch bodyResult {
        case let .failure(error):
            return Fail(
                outputType: Response.self,
                failure: HTTPError(
                    code: .unknown,
                    request: request,
                    response: nil,
                    underlyingError: error as NSError
                )
            ).eraseToAnyPublisher()
        case let .success(body):
            request.body = body

            return responder
                .respondTo(request)
                .decodedResponse(type: Response.self, decoder: decoder)
        }
    }

    public func execute<Response: Decodable>(
        _ get: Calls.Get<Response>
    ) -> APICallPublisher<Response> {
        var getComponents = components
        getComponents.queryItems = get.query

        var request = HTTPRequest(components: getComponents)
        request.path += "/" + get.path
        request.method = .get

        return responder
            .respondTo(request)
            .decodedResponse(type: Response.self, decoder: decoder)
    }
}
