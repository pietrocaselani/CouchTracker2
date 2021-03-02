public struct Genre: Codable, Hashable {
    public let name: String
    public let slug: String

    public init(name: String, slug: String) {
        self.name = name
        self.slug = slug
    }
}
