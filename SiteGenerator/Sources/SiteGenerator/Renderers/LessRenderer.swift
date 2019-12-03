//
//  LessRenderer.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

public final class LessRenderer: Renderer {
    public func canRenderFile(named filename: String, withExtension ext: String) -> Bool {
        ext == "less"
    }

    /// Parse Less and render it as CSS.
    public func render(fileURL: URL, targetDir: URL, delegate: RendererDelegate) throws {
        let filename = fileURL.lastPathComponent
        let cssURL = targetDir.appendingPathComponent(filename.replacingOccurrences(of: ".less", with: ".css"))
        let less = try String(contentsOf: fileURL, encoding: .utf8)
        let css = try parse(less)
        try css.write(to: cssURL, atomically: true, encoding: .utf8)
    }

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

    let lesscPath = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("node_modules")
        .appendingPathComponent("less")
        .appendingPathComponent("bin")
        .appendingPathComponent("lessc")
        .path

    @discardableResult
    func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
}
