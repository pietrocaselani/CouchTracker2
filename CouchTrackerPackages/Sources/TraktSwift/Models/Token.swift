import Foundation

public final class Token: NSObject, Codable, NSCoding, NSSecureCoding {
    public static let supportsSecureCoding = true

    public let accessToken: String
    public let expiresIn: TimeInterval
    public let refreshToken: String
    public let tokenType: String
    public let scope: String

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case scope
    }

    public init(
        accessToken: String,
        expiresIn: TimeInterval,
        refreshToken: String,
        tokenType: String,
        scope: String
    ) {
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.scope = scope
    }

    public required init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        tokenType = try container.decode(String.self, forKey: .tokenType)
        scope = try container.decode(String.self, forKey: .scope)
        expiresIn = try container.decode(TimeInterval.self, forKey: .expiresIn)
    }

    public required convenience init?(
        coder: NSCoder
    ) {
        let expiresIn = coder.decodeDouble(forKey: "expiresIn")

        guard
            let accessToken = coder.decodeObject(forKey: "accessToken") as? String,
            let refreshToken = coder.decodeObject(forKey: "refreshToken") as? String,
            let tokenType = coder.decodeObject(forKey: "tokenType") as? String,
            let scope = coder.decodeObject(forKey: "scope") as? String
        else { return nil }

        self.init(
            accessToken: accessToken,
            expiresIn: expiresIn,
            refreshToken: refreshToken,
            tokenType: tokenType,
            scope: scope
        )
    }

    public func encode(with coder: NSCoder) {
        coder.encode(accessToken, forKey: "accessToken")
        coder.encode(expiresIn, forKey: "expiresIn")
        coder.encode(refreshToken, forKey: "refreshToken")
        coder.encode(tokenType, forKey: "tokenType")
        coder.encode(scope, forKey: "scope")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(expiresIn, forKey: .expiresIn)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(tokenType, forKey: .tokenType)
        try container.encode(scope, forKey: .scope)
    }

    public override var hash: Int {
        hashValue
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let otherObject = object else { return false }
        guard let otherToken = otherObject as? Token else { return false }

        let isaccessToken = self.accessToken == otherToken.accessToken
        let isexpiresIn = self.expiresIn == otherToken.expiresIn
        let isrefreshToken = self.refreshToken == otherToken.refreshToken
        let istokenType = self.tokenType == otherToken.tokenType
        let isscope = self.scope == otherToken.scope

        return isaccessToken &&
            isexpiresIn &&
            isrefreshToken &&
            istokenType &&
            isscope
    }
}
