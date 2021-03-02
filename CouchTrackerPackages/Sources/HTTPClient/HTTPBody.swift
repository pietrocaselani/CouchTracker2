import Foundation
import protocol Combine.TopLevelEncoder

public struct HTTPBody: Equatable {
    public static let empty = HTTPBody(
        data: nil,
        additionalHeaders: nil
    )

    public let data: Data?
    public let additionalHeaders: [String: String]?

    public static func json<Model: Encodable>(
        encoder: JSONEncoder,
        value: Model
    ) throws -> HTTPBody {
        try .encodableModel(
            encoder: encoder,
            value: value,
            additionalHeaders: ["Content-Type": "application/json; charset=utf-8"]
        )
    }

    public static func encodableModel<Model: Encodable, Encoder>(
        encoder: Encoder,
        value: Model,
        additionalHeaders: [String: String]? = nil
    ) throws -> HTTPBody where Encoder: TopLevelEncoder, Encoder.Output == Data {
        .init(
            data: try encoder.encode(value),
            additionalHeaders: additionalHeaders
        )
    }

    public static func data(
        _ data: Data,
        additionalHeaders: [String: String]? = nil
    ) -> HTTPBody {
        .init(
            data: data,
            additionalHeaders: additionalHeaders
        )
    }
}
