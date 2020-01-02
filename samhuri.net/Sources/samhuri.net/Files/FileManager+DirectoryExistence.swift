//
//  FileManager+DirectoryExistence.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2020-01-01.
//

import Foundation

extension FileManager {
    func directoryExists(at fileURL: URL) -> Bool {
        var isDir: ObjCBool = false
        _ = fileExists(atPath: fileURL.path, isDirectory: &isDir)
        return isDir.boolValue
    }
}
