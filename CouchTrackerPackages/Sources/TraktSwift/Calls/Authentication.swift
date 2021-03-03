import RetrofitSwift

public enum AuthenticationCalls {
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

    public static func getAccessToken(
        _ body: AccessTokenBody
    ) -> Calls.Post<Token> {
        .init(
            path: "oauth/token",
            body: body
        )
    }

    public static func refreshToken(
        _ body: AccessTokenRefreshBody
    ) -> Calls.Post<Token> {
        .init(
            path: "oauth/token",
            body: body
        )
    }
}
