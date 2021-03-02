import Foundation

public struct HTTPError: Error, Equatable {
    public let code: URLError.Code
    public let request: HTTPRequest
    public let response: HTTPResponse?
    public let underlyingError: NSError?

    public init(
        code: URLError.Code,
        request: HTTPRequest,
        response: HTTPResponse?,
        underlyingError: NSError?
    ) {
        self.code = code
        self.request = request
        self.response = response
        self.underlyingError = underlyingError
    }

    static func invalidResponse(request: HTTPRequest) -> HTTPError {
        .init(
            code: .unknown,
            request: request,
            response: nil,
            underlyingError: nil
        )
    }

    static func urlError(request: HTTPRequest, error: URLError) -> HTTPError {
        return .init(
            code: error.code,
            request: request,
            response: nil,
            underlyingError: error as NSError
        )
    }
}
