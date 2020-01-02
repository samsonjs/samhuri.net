//
//  FilePermissions.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-24.
//

import Foundation

struct FilePermissions: Equatable, CustomStringConvertible {
    let user: Permissions
    let group: Permissions
    let other: Permissions

    var description: String {
        [user, group, other].map { $0.description }.joined()
    }

    static let fileDefault: FilePermissions = "rw-r--r--"
    static let directoryDefault: FilePermissions = "rwxr-xr-x"
}

extension FilePermissions {
    init?(string: String) {
        guard let user = Permissions(string: String(string.prefix(3))),
              let group = Permissions(string: String(string.dropFirst(3).prefix(3))),
              let other = Permissions(string: String(string.dropFirst(6).prefix(3)))
        else {
            return nil
        }

        self.user = user
        self.group = group
        self.other = other
    }
}

extension FilePermissions: RawRepresentable {
    var rawValue: Int16 {
        user.rawValue << 6 | group.rawValue << 3 | other.rawValue
    }

    init(rawValue: Int16) {
        user = Permissions(rawValue: rawValue >> 6 & 0b111)
        group = Permissions(rawValue: rawValue >> 3 & 0b111)
        other = Permissions(rawValue: rawValue >> 0 & 0b111)
    }
}

extension FilePermissions: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        guard let _ = FilePermissions(string: value) else {
            fatalError("Invalid FilePermissions string literal: \(value)")
        }
        self.init(string: value)!
    }
}
