//
//  FileWriting.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-24.
//

import Foundation

protocol FileWriting {
    func write(data: Data, to fileURL: URL) throws
    func write(data: Data, to fileURL: URL, permissions: FilePermissions) throws

    func write(string: String, to fileURL: URL) throws
    func write(string: String, to fileURL: URL, permissions: FilePermissions) throws
}

extension FileWriting {
    func write(data: Data, to fileURL: URL) throws {
        try write(data: data, to: fileURL, permissions: .fileDefault)
    }

    func write(string: String, to fileURL: URL) throws {
        try write(string: string, to: fileURL, permissions: .fileDefault)
    }
}
