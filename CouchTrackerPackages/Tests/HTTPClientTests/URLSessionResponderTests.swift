import XCTest
import Combine
@testable import HTTPClient
import HTTPClientTestable

final class URLSessionResponderTests: XCTestCase {
    private let fakeRequest = HTTPRequest()
    private var cancellables = Set<AnyCancellable>()
    private var responder: HTTPResponder!


    override func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]

        let session = URLSession(configuration: configuration)

        responder = HTTPResponder.fromURLSession(session)
    }

    override func tearDown() {
        URLProtocolMock.requestHandler = nil
        responder = nil

        super.tearDown()
    }

    func testWhenCompletesWithError() {
        URLProtocolMock.requestHandler = { urlRequest -> Result<(URLResponse, Data), URLError> in
            .failure(URLError(.badServerResponse))
        }

        var completion: Subscribers.Completion<HTTPError>?
        var receivedValues = [HTTPResponse]()

        let completionExpectation = expectation(description: "should complete")

        responder
            .respondTo(fakeRequest)
            .sink(
                receiveCompletion: {
                    completion = $0
                    completionExpectation.fulfill()
                },
                receiveValue: { receivedValues.append($0) }
            )
            .store(in: &cancellables)

        wait(for: [completionExpectation], timeout: 1)

        XCTAssertTrue(receivedValues.isEmpty)

        guard case let .failure(error) = completion else {
            return XCTFail("completion should be a failure")
        }

        XCTAssertEqual(error.code, .badServerResponse)
    }

    func testWhenCompletesWithSuccess() throws {
        let rawResponse = try XCTUnwrap(
            HTTPURLResponse(
                url: URL(fileURLWithPath: ""),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
        )
        URLProtocolMock.requestHandler = { urlRequest -> Result<(URLResponse, Data), URLError> in
            let data = "fake-response".data(using: .utf8) ?? Data()
            return .success((rawResponse, data))
        }

        var completion: Subscribers.Completion<HTTPError>?
        var receivedValues = [HTTPResponse]()

        let completionExpectation = expectation(description: "should complete")

        responder
            .respondTo(fakeRequest)
            .sink(
                receiveCompletion: {
                    completion = $0
                    completionExpectation.fulfill()
                },
                receiveValue: { receivedValues.append($0) }
            )
            .store(in: &cancellables)

        wait(for: [completionExpectation], timeout: 1)

        XCTAssertEqual(completion, .finished)

        let expectedResponse = HTTPResponse(
            response: rawResponse,
            request: fakeRequest,
            body: "fake-response".data(using: .utf8) ?? Data()
        )

        XCTAssertEqual(rawResponse, rawResponse)

        XCTAssertEqual(receivedValues, [expectedResponse])
    }
}
