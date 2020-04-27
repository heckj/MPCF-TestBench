import XCTest
@testable import XCTestStandalone

final class XCTestStandaloneTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(XCTestStandalone().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
