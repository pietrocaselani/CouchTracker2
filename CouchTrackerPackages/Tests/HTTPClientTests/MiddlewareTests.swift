import XCTest
import Combine
import HTTPClient
import HTTPClientTestable

final class MiddlewareTests: XCTestCase {
    private var fakeResponder: FakeResponder!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        fakeResponder = FakeResponder().then { request -> HTTPResponse in
            .fakeFrom(
                request: request,
                data: "Fake".data(using: .utf8) ?? Data()
            )
        }
    }

    override func tearDown() {
        fakeResponder = nil
        super.tearDown()
    }

    func testOrderOfMiddlewares() {
        func counterMiddlware(_ value: Int) -> HTTPMiddleware {
            HTTPMiddleware { request, responder -> HTTPCallPublisher in
                responder
                    .respondTo(request)
                    .map { response -> HTTPResponse in
                        let body = response.body.asString() ?? ""
                        let newBody = "\(body)\(value)".data(using: .utf8) ?? Data()
                        return .init(
                            response: response.rawResponse,
                            request: request,
                            body: newBody
                        )
                    }
                    .eraseToAnyPublisher()
            }
        }

        let responder = HTTPResponder.chaining(
            fakeResponder.makeResponder(),
            middlewares: [
                counterMiddlware(1),
                counterMiddlware(2),
                counterMiddlware(3)
            ]
        )

        var request = HTTPRequest()
        request.host = "api.github.com"
        request.path = "/zen"

        var completion: Subscribers.Completion<HTTPError>?
        var receivedValues = [String]()

        responder
            .respondTo(request)
            .compactMap { $0.body.asString() }
            .sink(
                receiveCompletion: { completion = $0 },
                receiveValue: { receivedValues.append($0) }
            ).store(in: &cancellables)

        XCTAssertEqual(completion, .finished)
        XCTAssertEqual(receivedValues, ["Fake123"])
    }
}
