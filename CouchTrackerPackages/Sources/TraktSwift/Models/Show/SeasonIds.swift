public struct SeasonIds: Codable, Equatable {
    public let tvdb: Int?
    public let tmdb: Int?
    public let trakt: Int
    public let tvrage: Int?

    private enum CodingKeys: String, CodingKey {
        case tvdb, tmdb, trakt, tvrage
    }

    public init(tvdb: Int?, tmdb: Int?, trakt: Int, tvrage: Int?) {
        self.tvdb = tvdb
        self.tmdb = tmdb
        self.trakt = trakt
        self.tvrage = tvrage
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        tvdb = try container.decodeIfPresent(Int.self, forKey: .tvdb)
        tmdb = try container.decodeIfPresent(Int.self, forKey: .tmdb)
        trakt = try container.decode(Int.self, forKey: .trakt)
        tvrage = try container.decodeIfPresent(Int.self, forKey: .tvrage)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(tvdb, forKey: .tvdb)
        try container.encodeIfPresent(tmdb, forKey: .tmdb)
        try container.encode(trakt, forKey: .trakt)
        try container.encodeIfPresent(tvrage, forKey: .tvrage)
    }
}
