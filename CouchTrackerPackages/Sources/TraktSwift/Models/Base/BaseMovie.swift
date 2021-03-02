import Foundation

public struct BaseMovie: Codable, Equatable {
    public let movie: Movie?
    public let collectedAt: Date?
    public let watchedAt: Date?
    public let listedAt: Date?
    public let plays: Int?
    
    private enum CodingKeys: String, CodingKey {
        case movie, plays
        case collectedAt = "collected_at"
        case watchedAt = "watched_at"
        case listedAt = "listed_at"
    }
    
    public init(
        movie: Movie?,
        collectedAt: Date?,
        watchedAt: Date?,
        listedAt: Date?,
        plays: Int?
    ) {
        self.movie = movie
        self.collectedAt = collectedAt
        self.watchedAt = watchedAt
        self.listedAt = listedAt
        self.plays = plays
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        movie = try container.decodeIfPresent(Movie.self, forKey: .movie)
        plays = try container.decodeIfPresent(Int.self, forKey: .plays)
        
        let collectedAt = try container.decodeIfPresent(String.self, forKey: .collectedAt)
        let listedAt = try container.decodeIfPresent(String.self, forKey: .listedAt)
        let watchedAt = try container.decodeIfPresent(String.self, forKey: .watchedAt)
        
        self.collectedAt = TraktDateTransformer.dateTimeTransformer.transformFromJSON(collectedAt)
        self.listedAt = TraktDateTransformer.dateTimeTransformer.transformFromJSON(listedAt)
        self.watchedAt = TraktDateTransformer.dateTimeTransformer.transformFromJSON(watchedAt)
    }
}
