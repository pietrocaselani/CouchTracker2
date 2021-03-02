public final class MovieIds: BaseIds {
    public let slug: String

    private enum CodingKeys: String, CodingKey {
        case slug
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        slug = try container.decode(String.self, forKey: .slug)

        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(slug, forKey: .slug)

        try super.encode(to: encoder)
    }

    public static func == (
        lhs: MovieIds,
        rhs: MovieIds
    ) -> Bool {
        let lhsBaseIds = lhs as BaseIds
        let rhsBaseIds = rhs as BaseIds

        return lhsBaseIds == rhsBaseIds && lhs.slug == rhs.slug
    }
}
