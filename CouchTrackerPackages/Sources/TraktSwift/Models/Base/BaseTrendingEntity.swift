public class BaseTrendingEntity: Codable, Equatable {
    public let watchers: Int

    public init(watchers: Int) {
        self.watchers = watchers
    }

    public static func == (
        lhs: BaseTrendingEntity,
        rhs: BaseTrendingEntity
    ) -> Bool {
        lhs.watchers == rhs.watchers
    }
}
