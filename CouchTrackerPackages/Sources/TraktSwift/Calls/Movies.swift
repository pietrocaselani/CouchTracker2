import RetrofitSwift

public enum MoviesCalls {
    public static func trending(
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
