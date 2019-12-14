import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(samhuri_netTests.allTests),
    ]
}
#endif
