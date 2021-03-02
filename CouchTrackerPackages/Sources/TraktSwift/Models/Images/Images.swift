public struct Images: Codable, Equatable {
    public let avatar: ImageSizes

    public init(avatar: ImageSizes) {
        self.avatar = avatar
    }
}
