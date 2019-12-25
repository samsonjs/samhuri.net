//
//  FileWriter.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-24.
//

import Foundation

/// On Linux umask doesn't seem to be respected and files are written without
/// group and other read permissions by default. This class explicitly sets
/// permissions and then it works properly on macOS and Linux.
final class FileWriter {
    typealias FileManager = DirectoryCreating & FilePermissionsSetting

    let fileManager: FileManager

    init(fileManager: FileManager = Foundation.FileManager.default) {
        self.fileManager = fileManager
    }
}

extension FileWriter: FileWriting {
    func write(data: Data, to fileURL: URL, permissions: FilePermissions) throws {
        try fileManager.createDirectory(at: fileURL.deletingLastPathComponent())
        try data.write(to: fileURL, options: .atomic)
        try fileManager.setPermissions(permissions, ofItemAt: fileURL)
    }

    func write(string: String, to fileURL: URL, permissions: FilePermissions) throws {
        try fileManager.createDirectory(at: fileURL.deletingLastPathComponent())
        try string.write(to: fileURL, atomically: true, encoding: .utf8)
        try fileManager.setPermissions(permissions, ofItemAt: fileURL)
    }
}
