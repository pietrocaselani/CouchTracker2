import XCTest
import Combine
import HTTPClient
import HTTPClientTestable

final class HTTPClientTests: XCTestCase {
    private var fakeResponder: FakeResponder!
    private var cancellables = Set<AnyCancellable>()
    private var httpResponder: HTTPResponder!

    override func setUp() {
        super.setUp()

        fakeResponder = FakeResponder()
        httpResponder = HTTPResponder.chaining(
            fakeResponder.makeResponder(),
            middlewares: []
        )
    }

    override func tearDown() {
        fakeResponder = nil
        httpResponder = nil
        super.tearDown()
    }

    func testCallsRequest() {
        var request = HTTPRequest()
        request.host = "api.github.com"
        request.path = "/zen"

        fakeResponder.then { request -> HTTPCallPublisher in
            XCTAssertEqual(request.url?.absoluteString, "https://api.github.com/zen")
            return .init(
                response: .fakeFrom(
                    request: request,
                    data: Data()
                )
            )
        }.then { request -> HTTPCallPublisher in
            XCTAssertEqual(request.url?.absoluteString, "https://api.github.com/zen")
            return .init(
                response: .fakeFrom(
                    request: request,
                    data: Data()
                )
            )
        }

        httpResponder
            .respondTo(request)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            ).store(in: &cancellables)

        httpResponder
            .respondTo(request)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            ).store(in: &cancellables)
    }

    func testAppendingMiddlewares() {
        var request = HTTPRequest()
        request.host = "api.github.com"
        request.path = "/zen"

        let queryItem = URLQueryItem(name: "apikey", value: "fake-key")

        let newResponder = httpResponder.appending(
            middlewares: .addQueryItem(item: queryItem)
        )

        fakeResponder.then { request -> HTTPCallPublisher in
            XCTAssertEqual(request.url?.absoluteString, "https://api.github.com/zen?apikey=fake-key")
            return .init(
                response: .fakeFrom(
                    request: request,
                    data: Data()
                )
            )
        }

        newResponder
            .respondTo(request)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            ).store(in: &cancellables)
    }
}
