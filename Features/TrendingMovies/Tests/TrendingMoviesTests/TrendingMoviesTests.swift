import XCTest
@testable import TrendingMovies

final class TrendingMoviesTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TrendingMoviesData().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
