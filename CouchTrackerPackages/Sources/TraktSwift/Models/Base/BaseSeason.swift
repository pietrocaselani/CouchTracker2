public struct BaseSeason: Codable, Equatable {
    public let number: Int
    public let episodes: [BaseEpisode]
    public let aired: Int?
    public let completed: Int?
    
    private enum CodingKeys: String, CodingKey {
        case number, episodes, aired, completed
    }
    
    public init(
        number: Int,
        episodes: [BaseEpisode],
        aired: Int?,
        completed: Int?
    ) {
        self.number = number
        self.episodes = episodes
        self.aired = aired
        self.completed = completed
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        number = try container.decode(Int.self, forKey: .number)
        episodes = try container.decode([BaseEpisode].self, forKey: .episodes)
        aired = try container.decodeIfPresent(Int.self, forKey: .aired)
        completed = try container.decodeIfPresent(Int.self, forKey: .completed)
    }
}
