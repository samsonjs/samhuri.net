//
//  Permissions.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-24.
//

import Foundation

struct Permissions: OptionSet {
    let rawValue: Int16

    static let execute = Permissions(rawValue: 1 << 0)
    static let write = Permissions(rawValue: 1 << 1)
    static let read = Permissions(rawValue: 1 << 2)

    init(rawValue: Int16) {
        self.rawValue = rawValue
    }

    init(string: String) {
        self.init(rawValue: 0)
        if string[string.startIndex] == "r" {
            insert(.read)
        }
        if string[string.index(string.startIndex, offsetBy: 1)] == "w" {
            insert(.write)
        }
        if string[string.index(string.startIndex, offsetBy: 2)] == "x" {
            insert(.execute)
        }
    }
}

extension Permissions: CustomStringConvertible {
    var description: String {
        [
            contains(.read) ? "r" : "-",
            contains(.write) ? "w" : "-",
            contains(.execute) ? "x" : "-",
        ].joined()
    }
}

extension Permissions: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(string: value)
    }
}
