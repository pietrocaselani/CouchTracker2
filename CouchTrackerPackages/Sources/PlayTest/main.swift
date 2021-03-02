import RetrofitSwift
import HTTPClient
import Foundation
import Combine

extension HTTPMiddleware {
  static func traktHeaders(clientID: String) -> Self {
    .init { request, responder -> HTTPCallPublisher in
      var request = request

      print(">>> Trakt headers")

      request.headers["trakt-api-key"] = clientID
      request.headers["trakt-api-version"] = "2"
      request.headers["Content-Type"] = "application/json"

      return responder.respondTo(request)
    }
  }
}

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

public struct Token: Decodable {
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String
    public let scope: String
}

/*
 public interface Authentication {

     @POST("oauth/token")
     Call<AccessToken> exchangeCodeForAccessToken(
             @Body AccessTokenRequest tokenRequest
     );

     @POST("oauth/token")
     Call<AccessToken> refreshAccessToken(
             @Body AccessTokenRefreshRequest refreshRequest
     );
 }
 */

let realClientID = ""

public struct TrendingMovie: Decodable {
    public struct Movie: Decodable {
        public let title: String?
    }

    public let movie: Movie
}

public enum TraktService {
    static func getAccessToken(
        _ body: AccessTokenBody
    ) -> Calls.Post<Token> {
        .init(
            path: "oauth/token",
            body: body
        )
    }

    static func refreshToken(
        _ body: AccessTokenRefreshBody
    ) -> Calls.Post<Token> {
        .init(
            path: "oauth/token",
            body: body
        )
    }

    static func trendingMovies(
        page: Int,
        limit: Int
    ) -> Calls.Get<[TrendingMovie]> {
        .init(
            path: "movies/trending",
            query: [
                .init(name: "page", value: String(page)),
                .init(name: "limit", value: String(limit))
            ]
        )
    }
}

func createTraktRetrofit() throws -> Retrofit {
    let apiHost = "api.trakt.tv"
    let baseURL = URL(string: "https://\(apiHost)")!
    let clientID = realClientID

    let session = URLSession.shared
    let client = HTTPClient.using(
        responder: .fromURLSession(session),
        middlewares: [
            .traktHeaders(clientID: clientID)
        ]
    )

    let traktEncoder = JSONEncoder()
    traktEncoder.keyEncodingStrategy = .convertToSnakeCase

    let traktDecoder = JSONDecoder()
    traktDecoder.keyDecodingStrategy = .convertFromSnakeCase
    //Add date strategy

    return try Retrofit(
        baseURL: baseURL,
        client: client,
        encoder: traktEncoder,
        decoder: traktDecoder
    )
}

var cancellables = Set<AnyCancellable>()
var completedGET = false
var completedPOST = false
func completed() -> Bool {
    completedGET && completedPOST
}

let retrofit = try createTraktRetrofit()

retrofit.execute(
    TraktService.trendingMovies(page: 1, limit: 30)
).sink { completion in
    print(">>> Completion: \(completion)")
    completedGET = true
} receiveValue: { movies in
    print(">>> Movies: \(movies)")
}.store(in: &cancellables)

while completed() == false {}