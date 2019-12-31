//
//  Date+SugarTests.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-31.
//

import XCTest
@testable import samhuri_net

extension Date {
    final class Tests: XCTestCase {
        var date: Date!

        override func setUp() {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: 0)!
            Date.defaultCalendar = calendar
            date = Date(timeIntervalSince1970: 0)
        }

        override func tearDown() {
            Date.defaultCalendar = .current
            date = nil
        }

        func testYear() {
            XCTAssertEqual(1970, date.year)
        }

        func testMonth() {
            XCTAssertEqual(1, date.month)
        }

        func testDay() {
            XCTAssertEqual(1, date.day)
        }

        static var allTests = [
            ("testYear", testYear),
            ("testMonth", testMonth),
            ("testDay", testDay),
        ]
    }
}
