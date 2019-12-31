//
//  FilePermissionsTests.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-31.
//

import XCTest
@testable import samhuri_net

extension FilePermissions {
    final class Tests: XCTestCase {
        func testDescription() {
            XCTAssertEqual("---------", FilePermissions(user: "---", group: "---", other: "---").description)
            XCTAssertEqual("r--r--r--", FilePermissions(user: "r--", group: "r--", other: "r--").description)
            XCTAssertEqual("-w--w--w-", FilePermissions(user: "-w-", group: "-w-", other: "-w-").description)
            XCTAssertEqual("--x--x--x", FilePermissions(user: "--x", group: "--x", other: "--x").description)
            XCTAssertEqual("rwxr-xr--", FilePermissions(user: "rwx", group: "r-x", other: "r--").description)
        }

        func testInitFromString() {
            XCTAssertEqual(FilePermissions(user: "---", group: "---", other: "---"), FilePermissions(string: "---------"))
            XCTAssertEqual(FilePermissions(user: "r--", group: "r--", other: "r--"), FilePermissions(string: "r--r--r--"))
            XCTAssertEqual(FilePermissions(user: "-w-", group: "-w-", other: "-w-"), FilePermissions(string: "-w--w--w-"))
            XCTAssertEqual(FilePermissions(user: "--x", group: "--x", other: "--x"), FilePermissions(string: "--x--x--x"))
            XCTAssertEqual(FilePermissions(user: "rwx", group: "r-x", other: "r--"), FilePermissions(string: "rwxr-xr--"))

            // Refuses to initialize with nonsense.
            XCTAssertNil(FilePermissions(string: "abcdefghi"))
            XCTAssertNil(FilePermissions(string: "abcrwxrwx"))
            XCTAssertNil(FilePermissions(string: "rwxabcrwx"))
            XCTAssertNil(FilePermissions(string: "rwxrwxabc"))
        }

        func testInitFromRawValue() {
            XCTAssertEqual("---------", FilePermissions(rawValue: 0o000))
            XCTAssertEqual("rwxr-xr-x", FilePermissions(rawValue: 0o755))
            XCTAssertEqual("rw-r--r--", FilePermissions(rawValue: 0o644))
            XCTAssertEqual("rw-------", FilePermissions(rawValue: 0o600))
            XCTAssertEqual("rwxrwxrwx", FilePermissions(rawValue: 0o777))
        }

        func testRawValue() {
            XCTAssertEqual(0o000, FilePermissions(string: "---------")!.rawValue)
            XCTAssertEqual(0o755, FilePermissions(string: "rwxr-xr-x")!.rawValue)
            XCTAssertEqual(0o644, FilePermissions(string: "rw-r--r--")!.rawValue)
            XCTAssertEqual(0o600, FilePermissions(string: "rw-------")!.rawValue)
            XCTAssertEqual(0o777, FilePermissions(string: "rwxrwxrwx")!.rawValue)
        }

        func testExpressibleByStringLiteral() {
            XCTAssertEqual(FilePermissions(user: "rwx", group: "r-x", other: "r-x"), "rwxr-xr-x")
        }

        static var allTests = [
            ("testDescription", testDescription),
            ("testInitFromString", testInitFromString),
            ("testInitFromRawValue", testInitFromRawValue),
            ("testRawValue", testRawValue),
            ("testExpressibleByStringLiteral", testExpressibleByStringLiteral),
        ]
    }
}
