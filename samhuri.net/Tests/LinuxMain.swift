import XCTest

import samhuri.net.Tests

var tests = [XCTestCaseEntry]()
tests += samhuri.net.Tests.allTests()
XCTMain(tests)
