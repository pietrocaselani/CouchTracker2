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
