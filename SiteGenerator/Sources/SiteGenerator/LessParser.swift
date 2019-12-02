//
//  LessParser.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

/// Shells out to lessc on the command line.
final class LessParser {
    /// Parses Less and returns CSS.
    func parse(_ less: String) throws -> String {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        defer {
            _ = try? FileManager.default.removeItem(at: tempDir)
        }

        let timestamp = Date().timeIntervalSince1970
        let lessURL = tempDir.appendingPathComponent("LessParser-in-\(timestamp).less")
        let cssURL = tempDir.appendingPathComponent("LessParser-out-\(timestamp).css")
        try less.write(to: lessURL, atomically: true, encoding: .utf8)
        shell(lesscPath, lessURL.path, cssURL.path)
        return try String(contentsOf: cssURL, encoding: .utf8)
    }

    private let lesscPath = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .appendingPathComponent("node_modules")
        .appendingPathComponent("less")
        .appendingPathComponent("bin")
        .appendingPathComponent("lessc")
        .path

    @discardableResult
    private func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
}
