import Combine
import HTTPClient
import Foundation

public typealias APICallPublisher<T> = AnyPublisher<T, HTTPError>

public extension HTTPCallPublisher where Output == HTTPResponse {
    func decodedResponse<Model: Decodable, Decoder>(
        type: Model.Type,
        decoder: Decoder
    ) -> APICallPublisher<Model> where Decoder: TopLevelDecoder, Decoder.Input == Data {
        self.flatMap { response -> APICallPublisher<Model> in
            do {
                let model = try response.body.decoded(
                    type: type,
                    decoder: decoder
                )
                return Just(model)
                    .setFailureType(to: HTTPError.self)
                    .eraseToAnyPublisher()
            } catch {
                return Fail(
                    outputType: Model.self,
                    failure: HTTPError(
                        code: .cannotParseResponse,
                        request: response.request,
                        response: response,
                        underlyingError: error as NSError
                    )
                ).eraseToAnyPublisher()
            }
        }.eraseToAnyPublisher()
    }
}
