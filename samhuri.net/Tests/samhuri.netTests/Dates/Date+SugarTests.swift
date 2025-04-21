//
//  Date+SugarTests.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-31.
//

import Foundation
@testable import samhuri_net
import Testing

class DateSugarTests {
    let date: Date

    init() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        Date.defaultCalendar = calendar
        date = Date(timeIntervalSince1970: 0)
    }

    deinit {
        Date.defaultCalendar = .current
    }

    @Test func year() {
        #expect(date.year == 1970)
    }

    @Test func month() {
        #expect(date.month == 1)
    }

    @Test func day() {
        #expect(date.day == 1)
    }
}
