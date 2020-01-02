//
//  Month.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

struct Month: Equatable {
    static let all = (1 ... 12).map(Month.init(_:))

    static let names = [
        "January", "Februrary", "March", "April",
        "May", "June", "July", "August",
        "September", "October", "November", "December"
    ]

    let number: Int

    init(_ number: Int) {
        precondition((1 ... 12).contains(number), "Month number must be from 1 to 12, got \(number)")
        self.number = number
    }

    init(_ name: String) {
        precondition(Month.names.contains(name), "Month name is unknown: \(name)")
        self.number = 1 + Month.names.firstIndex(of: name)!
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
        self.init(value)
    }
}

extension Month: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(value)
    }
}
