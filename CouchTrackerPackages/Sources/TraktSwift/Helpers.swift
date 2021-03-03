import Foundation

extension Extended {
    func asQueryItem(
        name: String = "extended"
    ) -> URLQueryItem {
        .init(name: name, value: rawValue)
    }
}
