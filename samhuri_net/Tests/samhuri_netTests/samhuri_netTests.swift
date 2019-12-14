import XCTest
@testable import samhuri_net

final class samhuri_netTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(samhuri_net().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
