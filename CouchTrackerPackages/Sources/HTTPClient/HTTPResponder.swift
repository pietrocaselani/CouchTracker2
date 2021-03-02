import Combine

public typealias HTTPCallPublisher = AnyPublisher<HTTPResponse, HTTPError>

public struct HTTPResponder {
    public let respondTo: (HTTPRequest) -> HTTPCallPublisher

    public init(
        respondTo: @escaping (HTTPRequest) -> HTTPCallPublisher
    ) {
        self.respondTo = respondTo
    }

    public static func chaining(
        responder: HTTPResponder,
        middlewares: [HTTPMiddleware]
    ) -> Self {
        .init(
            respondTo: { request in
                middlewares
                    .makeResponder(chainingTo: responder)
                    .respondTo(request)
            }
        )
    }

    public func appending(
        middlewares: HTTPMiddleware...
    ) -> Self {
        .chaining(
            responder: self,
            middlewares: middlewares
        )
    }
}
