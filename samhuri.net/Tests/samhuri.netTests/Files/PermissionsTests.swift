//
//  PermissionsTests.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-31.
//

import XCTest
@testable import samhuri_net

extension Permissions {
    final class Tests: XCTestCase {
        func testOptionsAreMutuallyExclusive() {
            // If any of the bits overlap then the `or` value will be less than the sum of the raw values.
            let allValues = [Permissions.execute, Permissions.write, Permissions.read].map { $0.rawValue }
            XCTAssertEqual(allValues.reduce(0, +), allValues.reduce(0, |))
        }

        func testRawValuesAreUnixy() {
            XCTAssertEqual(0o0, Permissions.none.rawValue)
            XCTAssertEqual(0o4, Permissions.read.rawValue)
            XCTAssertEqual(0o2, Permissions.write.rawValue)
            XCTAssertEqual(0o1, Permissions.execute.rawValue)
        }

        func testInitFromString() {
            XCTAssertEqual([.none], Permissions(string: "---"))
            XCTAssertEqual([.execute], Permissions(string: "--x"))
            XCTAssertEqual([.write], Permissions(string: "-w-"))
            XCTAssertEqual([.read], Permissions(string: "r--"))

            XCTAssertEqual([.read, .write], Permissions(string: "rw-"))
            XCTAssertEqual([.read, .execute], Permissions(string: "r-x"))
            XCTAssertEqual([.write, .execute], Permissions(string: "-wx"))
            XCTAssertEqual([.read, .write, .execute], Permissions(string: "rwx"))

            // Refuses to initialize with nonsense.
            XCTAssertNil(Permissions(string: "abc"))
            XCTAssertNil(Permissions(string: "awx"))
            XCTAssertNil(Permissions(string: "rax"))
            XCTAssertNil(Permissions(string: "rwa"))
        }

        func testDescription() {
            XCTAssertEqual("---", Permissions.none.description)
            XCTAssertEqual("r--", Permissions.read.description)
            XCTAssertEqual("-w-", Permissions.write.description)
            XCTAssertEqual("--x", Permissions.execute.description)
            XCTAssertEqual("rw-", Permissions(arrayLiteral: [.read, .write]).description)
            XCTAssertEqual("r-x", Permissions(arrayLiteral: [.read, .execute]).description)
            XCTAssertEqual("-wx", Permissions(arrayLiteral: [.write, .execute]).description)
            XCTAssertEqual("rwx", Permissions(arrayLiteral: [.read, .write, .execute]).description)
        }

        func testExpressibleByStringLiteral() {
            XCTAssertEqual(Permissions.read, "r--")
        }

        static var allTests = [
            ("testOptionsAreMutuallyExclusive", testOptionsAreMutuallyExclusive),
            ("testRawValuesAreUnixy", testRawValuesAreUnixy),
            ("testInitFromString", testInitFromString),
            ("testDescription", testDescription),
            ("testExpressibleByStringLiteral", testExpressibleByStringLiteral),
        ]
    }
}
