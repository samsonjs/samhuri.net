import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(samhuri.net.Tests.allTests),
    ]
}
#endif
