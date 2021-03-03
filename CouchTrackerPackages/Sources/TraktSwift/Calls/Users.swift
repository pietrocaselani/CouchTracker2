import RetrofitSwift

public enum UserCalls {
    public static func settings() -> Calls.Get<Settings> {
        .init(path: "users/settings")
    }
}
