public struct Settings: Codable, Equatable {
    public let user: User

    public init(user: User) {
        self.user = user
    }
}
