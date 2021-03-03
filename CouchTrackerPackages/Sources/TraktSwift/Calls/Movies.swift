import RetrofitSwift

private enum MoviesCalls {
    static func trending(
        page: Int,
        limit: Int,
        extended: Extended
    ) -> Calls.Get<[TrendingMovie]> {
        .init(
            path: "movies/trending",
            query: [
                .init(name: "page", value: String(page)),
                .init(name: "limit", value: String(limit)),
                extended.asQueryItem()
            ]
        )
    }

    public static func summary(
        movieId: String,
        extended: Extended
    ) -> Calls.Get<Movie> {
        .init(
            path: "movies/\(movieId)",
            query: [extended.asQueryItem()]
        )
    }
}

public struct MoviesService {
    private let retrofit: Retrofit

    init(retrofit: Retrofit) {
        self.retrofit = retrofit
    }

    public func trending(
        page: Int,
        limit: Int,
        extended: Extended
    ) -> APICallPublisher<[TrendingMovie]> {
        retrofit.execute(
            MoviesCalls.trending(page: page, limit: limit, extended: extended)
        )
    }

    public func summary(
        movieId: String,
        extended: Extended
    ) -> APICallPublisher<Movie> {
        retrofit.execute(
            MoviesCalls.summary(movieId: movieId, extended: extended)
        )
    }
}
