//
//  FilePermissionsSetting.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-24.
//

import Foundation

protocol FilePermissionsSetting {
    func setPermissions(_ permissions: FilePermissions, ofItemAt fileURL: URL) throws
}

extension FileManager: FilePermissionsSetting {
    func setPermissions(_ permissions: FilePermissions, ofItemAt fileURL: URL) throws {
        let attributes: [FileAttributeKey: Any] = [
            .posixPermissions: permissions.rawValue,
        ]
        try setAttributes(attributes, ofItemAtPath: fileURL.path)
    }
}
