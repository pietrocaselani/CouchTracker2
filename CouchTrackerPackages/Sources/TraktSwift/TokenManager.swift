import Foundation

private let tokenKey = "trakt_token"
private let tokenExpirationDateKey = "trakt_token_experiration_date"

public struct TokenManager {
    public enum TokenStatus: Equatable {
        case valid(Token)
        case refresh(Token)
        case invalid

        var token: Token? {
            switch self {
            case .invalid: return nil
            case let .valid(token),
                 let .refresh(token): return token
            }
        }
    }

    public let tokenStatus: () -> TokenStatus
    public let saveToken: (Token) -> Result<Token, Error>

    public init(
        tokenStatus: @escaping () -> TokenStatus,
        saveToken: @escaping  (Token) -> Result<Token, Error>
    ) {
        self.tokenStatus = tokenStatus
        self.saveToken = saveToken
    }

    public static func from(
        userDefaults: UserDefaults,
        date: @escaping () -> Date
    ) -> TokenManager {
        .init(
            tokenStatus: {
                let tokenData = userDefaults.object(forKey: tokenKey) as? Data

                let token = tokenData.flatMap {
                    try? NSKeyedUnarchiver.unarchivedObject(
                        ofClass: Token.self,
                        from: $0
                    )
                }

                guard let validToken = token else {
                    return TokenStatus.invalid
                }

                let tokenDate = userDefaults.object(
                    forKey: tokenExpirationDateKey
                )

                guard let expirationDate = tokenDate as? Date else {
                    return TokenStatus.refresh(validToken)
                }

                let now = date()
                let result = expirationDate.compare(now)

                return result == .orderedDescending
                    ? TokenStatus.valid(validToken)
                    : TokenStatus.refresh(validToken)
            },
            saveToken: { (token: Token) -> Result<Token, Error> in
                Result {
                    let tokenData = try NSKeyedArchiver.archivedData(
                        withRootObject: token,
                        requiringSecureCoding: true
                    )

                    let expirationDate = Date(
                        timeIntervalSince1970: date().timeIntervalSince1970 + token.expiresIn
                    )

                    userDefaults.set(tokenData, forKey: tokenKey)
                    userDefaults.set(expirationDate, forKey: tokenExpirationDateKey)

                    return token
                }
            }
        )
    }
}
