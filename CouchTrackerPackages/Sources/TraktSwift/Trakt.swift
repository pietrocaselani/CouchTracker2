import RetrofitSwift
import HTTPClient
import Foundation
import Combine

// swiftlint:disable force_unwrapping
private let baseURL = URL(string: "https://\(apiHost)")!
// swiftlint:enable force_unwrapping

private let apiHost = "api.trakt.tv"
private let apiVersion = "2"

public final class Trakt {
    public struct AuthData {
        public let clientSecret: String
        public let redirectURL: URL

        public init(
            clientSecret: String,
            redirectURL: URL
        ) {
            self.clientSecret = clientSecret
            self.redirectURL = redirectURL
        }
    }

    public struct Credentials {
        public let clientId: String
        public let authData: AuthData?

        public init(
            clientId: String,
            authData: AuthData?
        ) {
            self.clientId = clientId
            self.authData = authData
        }
    }

    public let authenticator: Authenticator?
    public let retrofit: Retrofit

    public lazy var movies = MoviesService(retrofit: retrofit)

    public init(
        responder: HTTPResponder,
        tokenManager: TokenManager,
        credentials: Credentials
    ) throws {
        let retrofit = try Retrofit.make(
            baseURL: baseURL,
            responder: .chaining(
                responder,
                middlewares: [.traktHeaders(clientID: credentials.clientId)]
            ),
            encoder: .init(),
            decoder: .init()
        )

        if let authData = credentials.authData {
            self.authenticator = try Authenticator(
                manager: tokenManager,
                retrofit: retrofit,
                clientID: credentials.clientId,
                authData: authData
            )

            let finalRetrofit = retrofit.chaining(
                middlewares: [
                    .token(
                        clientID: credentials.clientId,
                        authData: authData,
                        tokenManager: tokenManager,
                        tokenRefresher: { token -> APICallPublisher<Token> in
                            refreshToken(
                                retrofit: retrofit,
                                clientID: credentials.clientId,
                                authData: authData,
                                refreshToken: token.refreshToken
                            )
                        }
                    )
                ]
            )

            self.retrofit = finalRetrofit
        } else {
            self.authenticator = nil
            self.retrofit = retrofit
        }
    }
}

private func refreshToken(
    retrofit: Retrofit,
    clientID: String,
    authData: Trakt.AuthData,
    refreshToken: String
) -> APICallPublisher<Token> {
    retrofit.execute(
        AuthenticationCalls.refreshToken(
            .init(
                clientID: clientID,
                clientSecret: authData.clientSecret,
                refreshToken: refreshToken,
                redirectURL: authData.redirectURL.absoluteString
            )
        )
    )
}

private extension HTTPMiddleware {
    static func traktHeaders(clientID: String) -> Self {
        .init { request, responder -> HTTPCallPublisher in
            var request = request

            print(">>> Trakt headers")

            request.headers["trakt-api-key"] = clientID
            request.headers["trakt-api-version"] = apiVersion
            request.headers["Content-Type"] = "application/json"

            return responder.respondTo(request)
        }
    }

    static func token(
        clientID: String,
        authData: Trakt.AuthData,
        tokenManager: TokenManager,
        tokenRefresher: @escaping (Token) -> APICallPublisher<Token>
    ) -> Self {
        .init { request, responder -> HTTPCallPublisher in
            var request = request
            let tokenStatus = tokenManager.tokenStatus()

            switch tokenStatus {
            case let .valid(token):
                print(">>> has valid token")
                return responder.respondTo(request.authorize(token))
            case let .refresh(token):
                print(">>> refreshing token")
                return tokenRefresher(token)
                .saveToken(tokenManager)
                .flatMap { token in
                    responder.respondTo(request.authorize(token))
                }
                .eraseToAnyPublisher()
            case .invalid:
                return responder.respondTo(request)
            }
        }
    }
}

private extension HTTPRequest {
    mutating func authorize(_ token: Token) -> HTTPRequest {
        self.headers["Authorization"] = "Bearer " + token.accessToken
        return self
    }
}
