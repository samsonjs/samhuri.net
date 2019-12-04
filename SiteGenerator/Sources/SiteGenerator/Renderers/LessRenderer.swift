//
//  LessRenderer.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

public final class LessRenderer: Renderer {
    enum Error: Swift.Error {
        case invalidCSSData(Data)
    }

    public func canRenderFile(named filename: String, withExtension ext: String) -> Bool {
        ext == "less"
    }

    /// Parse Less and render it as CSS.
    public func render(fileURL: URL, targetDir: URL, templateRenderer: TemplateRenderer) throws {
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

        let lessIn = Pipe()
        lessIn.fileHandleForWriting.write(Data(less.utf8))
        try lessIn.fileHandleForWriting.close()
        let cssOut = Pipe()
        shell(lesscPath, "-", stdin: lessIn, stdout: cssOut)
        let cssData = cssOut.fileHandleForReading.readDataToEndOfFile()
        _ = try? cssOut.fileHandleForReading.close()
        guard let css = String(data: cssData, encoding: .utf8) else {
            throw Error.invalidCSSData(cssData)
        }
        return css
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
    func shell(_ args: String..., stdin: Pipe? = nil, stdout: Pipe? = nil, stderr: Pipe? = nil) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.standardInput = stdin
        task.standardOutput = stdout
        task.standardError = stderr
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
}
