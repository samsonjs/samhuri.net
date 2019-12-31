import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Date.Tests.allTests),
        testCase(Permissions.Tests.allTests),
        testCase(FilePermissions.Tests.allTests),
        testCase(samhuri.net.Tests.allTests),
    ]
}
#endif
