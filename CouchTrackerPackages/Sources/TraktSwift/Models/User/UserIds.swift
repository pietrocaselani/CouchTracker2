public struct UserIds: Codable, Equatable {
    public let slug: String

    public init(slug: String) {
        self.slug = slug
    }
}
