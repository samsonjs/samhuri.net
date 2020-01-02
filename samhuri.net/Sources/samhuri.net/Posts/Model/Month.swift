//
//  Month.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

struct Month: Equatable {
    static let all = names.map(Month.init(_:))

    static let names = [
        "January", "February", "March", "April",
        "May", "June", "July", "August",
        "September", "October", "November", "December"
    ]

    let number: Int

    init?(_ number: Int) {
        guard number < Month.all.count else {
            return nil
        }
        self.number = number
    }

    init?(_ name: String) {
        guard let index = Month.names.firstIndex(of: name) else {
            return nil
        }
        self.number = index + 1
    }

    init(_ date: Date) {
        self.init(date.month)!
    }

    var padded: String {
        String(format: "%02d", number)
    }

    var name: String {
        Month.names[number - 1]
    }

    var abbreviation: String {
        String(name.prefix(3))
    }
}

extension Month: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(number)
    }
}

extension Month: Comparable {
    static func <(lhs: Month, rhs: Month) -> Bool {
        lhs.number < rhs.number
    }
}

extension Month: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        guard let _ = Month(value) else {
            fatalError("Invalid month number in string literal: \(value)")
        }
        self.init(value)!
    }
}

extension Month: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        guard let _ = Month(value) else {
            fatalError("Invalid month name in string literal: \(value)")
        }
        self.init(value)!
    }
}
