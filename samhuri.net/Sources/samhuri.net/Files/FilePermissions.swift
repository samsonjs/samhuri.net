//
//  FilePermissions.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-24.
//

import Foundation

struct FilePermissions: CustomStringConvertible {
    let user: Permissions
    let group: Permissions
    let other: Permissions

    var description: String {
        [user, group, other].map { $0.description }.joined()
    }

    static let `default`: FilePermissions = "rw-r--r--"
    static let directoryDefault: FilePermissions = "rwxr-xr-x"
}

extension FilePermissions {
    init(string: String) {
        user = Permissions(string: String(string.prefix(3)))
        group = Permissions(string: String(string.dropFirst(3).prefix(3)))
        other = Permissions(string: String(string.dropFirst(6).prefix(3)))
    }
}

extension FilePermissions: RawRepresentable {
    var rawValue: Int16 {
        user.rawValue << 6 | group.rawValue << 3 | other.rawValue
    }

    init(rawValue: Int16) {
        user = Permissions(rawValue: rawValue >> 6 & 7)
        group = Permissions(rawValue: rawValue >> 3 & 7)
        other = Permissions(rawValue: rawValue >> 0 & 7)
    }
}

extension FilePermissions: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(string: value)
    }
}
