import RetrofitSwift
import HTTPClient
import Foundation
import Combine
import TraktSwift

extension AnyPublisher where Failure == HTTPError {
    func toResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        map(Result<Output, Failure>.success)
            .catch { httpError in
                Just(Result<Output, Failure>.failure(httpError))
            }.eraseToAnyPublisher()
    }
}

var cancellables = Set<AnyCancellable>()
var completedAllRequests = false

func completed() -> Bool {
    completedAllRequests
}

private enum Secrets {
    enum Trakt {
        static let clientId = ""
        static let clientSecret = ""
        static let redirectURL = URL(string: "")!
    }
}

let trakt = try Trakt(
    responder: .fromURLSession(.shared),
    tokenManager: .from(userDefaults: UserDefaults.standard, date: Date.init),
    credentials: .init(
        clientId: Secrets.Trakt.clientId,
        authData: .init(
            clientSecret: Secrets.Trakt.clientSecret,
            redirectURL: Secrets.Trakt.redirectURL
        )
    )
)

trakt
    .movies
    .trending(page: 0, limit: 30, extended: .default)
    .map { movies in
        movies.compactMap(\.movie.title)
    }
    .eraseToAnyPublisher()
    .toResult()
    .sink { result in
        print(">>> \(result)")
        completedAllRequests = true
    }.store(in: &cancellables)

while completed() == false {}
