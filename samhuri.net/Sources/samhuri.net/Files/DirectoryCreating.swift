//
//  DirectoryCreating.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-24.
//

import Foundation

protocol DirectoryCreating {
    func createDirectory(at url: URL) throws
}

extension FileManager: DirectoryCreating {
    func createDirectory(at url: URL) throws {
        try createDirectory(at: url, withIntermediateDirectories: true, attributes: [
            .posixPermissions: FilePermissions.directoryDefault.rawValue,
        ])
    }
}
