import Foundation
import HTTPClient
import RetrofitSwift
import Combine

// swiftlint:disable force_unwrapping
private let baseURL = URL(string: "https://\(apiHost)")!
private let siteURL = URL(string: "https://trakt.tv")!
// swiftlint:enable force_unwrapping

private let apiHost = "api.trakt.tv"

public enum AuthenticationResult: Equatable {
    case authenticated
    case undetermined
}

public struct Authenticator {
    public let oauthURL: URL

    private let authData: Trakt.AuthData
    private let clientID: String
    private let tokenManager: TokenManager
    private let retrofit: Retrofit

    init(
        manager: TokenManager,
        retrofit: Retrofit,
        clientID: String,
        authData: Trakt.AuthData
    ) throws {
        guard let url = createOAuthURL(
            clientID: clientID,
            redirectURL: authData.redirectURL
        ) else {
            throw TraktError.failedToCreateOAuthURL
        }

        self.retrofit = retrofit
        self.oauthURL = url
        self.clientID = clientID
        self.authData = authData
        self.tokenManager = manager
    }

    public func finishAuthentication(
        request: URLRequest
    ) -> AnyPublisher<AuthenticationResult, HTTPError> {
        guard
            let url = request.url,
            let host = url.host, authData.redirectURL.host?.contains(host) == true
        else {
            return Just(AuthenticationResult.undetermined)
                .setFailureType(to: HTTPError.self)
                .eraseToAnyPublisher()
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard
            let codeItemValue = components?.queryItems?.first(where: { $0.name == "code" })?.value
        else {
            return Just(AuthenticationResult.undetermined)
                .setFailureType(to: HTTPError.self)
                .eraseToAnyPublisher()
        }

        return retrofit.execute(
            AuthenticationCalls.getAccessToken(
                .init(
                    clientID: clientID,
                    clientSecret: authData.clientSecret,
                    code: codeItemValue,
                    redirectURL: authData.redirectURL.absoluteString
                )
            )
        )
        .saveToken(tokenManager)
        .map { _ in AuthenticationResult.authenticated }
        .eraseToAnyPublisher()
    }
}

extension APICallPublisher where Output == Token, Failure == HTTPError {
    func saveToken(_ manager: TokenManager) -> APICallPublisher<Token> {
        self.handleEvents(
            receiveOutput: { token in
                _ = manager.saveToken(token)
            }
        ).eraseToAnyPublisher()
    }
}

private func createOAuthURL(
    clientID: String,
    redirectURL: URL
) -> URL? {
    guard var components = URLComponents(
        url: siteURL,
        resolvingAgainstBaseURL: false
    ) else { return nil }

    components.path = "/oauth/authorize"
    components.queryItems = [
        .init(name: "response_type", value: "code"),
        .init(name: "client_id", value: clientID),
        .init(name: "redirect_uri", value: redirectURL.absoluteString)
    ]

    return components.url
}
