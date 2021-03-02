import HTTPClient

public struct AccessTokenService {
    public struct AccessTokenRefreshBody: Encodable {
        public let grantType = "refresh_token"
        public let clientID, clientSecret: String
        public let refreshToken, redirectURL: String
    }

    public struct AccessTokenBody: Encodable {
        public let grantType = "authorization_code"
        public let clientID, clientSecret: String
        public let code, redirectURL: String
    }


//    let get: (Parameters) -> APICallPublisher<Token>

//    func get(
//        _ parameters: Parameters
//    ) -> (HTTPClient) -> APICallPublisher<Token> {
//
//    }

//    static func from(apiClient: APIClient) -> Self {
//        .init(get: { params in
//            apiClient.post(
//                .init(
//                    path: "oauth/token",
//                    body: .encodableModel(value: params)
//                )
//            ).decoded(as: Token.self)
//        })
//    }
}

public struct RefreshTokenService {
//    public struct Parameters: Encodable {
//    }
//
//    let refresh: (Parameters) -> APICallPublisher<Token>

//    static func from(apiClient: APIClient) -> Self {
//        .init(refresh: { params in
//            apiClient.post(
//                .init(
//                    path: "oauth/token",
//                    body: .encodableModel(value: params)
//                )
//            ).decoded(as: Token.self)
//        })
//    }
}
