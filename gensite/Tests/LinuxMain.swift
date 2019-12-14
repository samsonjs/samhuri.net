import XCTest

import gensiteTests

var tests = [XCTestCaseEntry]()
tests += gensiteTests.allTests()
XCTMain(tests)
