import Foundation

public struct HTTPRequest: Equatable {
    private var urlComponents = URLComponents()
    public var method: HTTPMethod = .get
    public var headers: [String: String] = [:]
    public var body: HTTPBody = .empty

    public init(components: URLComponents) {
        self.urlComponents = components
    }

    public init(
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: HTTPBody = .empty
    ) {
        urlComponents.scheme = "https"
        self.method = method
        self.headers = headers
        self.body = body
    }

    public var scheme: String {
        urlComponents.scheme ?? "https"
    }

    public var host: String? {
        get { urlComponents.host }
        set { urlComponents.host = newValue }
    }

    public var path: String {
        get { urlComponents.path }
        set { urlComponents.path = newValue }
    }

    public var query: [URLQueryItem] {
        get { urlComponents.queryItems ?? [] }
        set { urlComponents.queryItems = newValue }
    }

    public var url: URL? {
        try? makeURLRequest().map(\.url).get()
    }

    func makeURLRequest() -> Result<URLRequest, HTTPError> {
        guard let urlToRun = urlComponents.url else {
            return .failure(.urlError(request: self, error: .init(.badURL)))
        }

        var urlRequest = URLRequest(url: urlToRun)
        urlRequest.httpMethod = method.rawValue

        headers.forEach { header, value in
            urlRequest.addValue(value, forHTTPHeaderField: header)
        }

        if let data = body.data {
            body.additionalHeaders?.forEach { header, value in
                urlRequest.addValue(value, forHTTPHeaderField: header)
            }

            urlRequest.httpBody = data
        }

        return .success(urlRequest)
    }
}
