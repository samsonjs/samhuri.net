//
//  Generator.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation
import Ink
import PathKit
import Stencil

public final class Generator {
    private let fileManager: FileManager = .default

    public let site: Site
    public let sourceURL: URL

    private let lessParser: LessParser
    private let mdParser: MarkdownParser
    private let templateRenderer: Environment

    public init(sourceURL: URL) throws {
        let siteURL = sourceURL.appendingPathComponent("site.json")
        self.site = try Site.decode(from: siteURL)
        self.sourceURL = sourceURL

        let templatesURL = sourceURL.appendingPathComponent("templates")
        self.templateRenderer = Environment(loader: FileSystemLoader(paths: [Path(templatesURL.path)]))

        self.lessParser = LessParser()
        self.mdParser = MarkdownParser()
    }

    public func generate(targetURL: URL) throws {
        // Iterate through all files in public recursively and render or copy each one
        let publicURL = sourceURL.appendingPathComponent("public")
        try renderPath(publicURL.path, to: targetURL)
    }

    func renderPath(_ path: String, to targetURL: URL) throws {
        for filename in try fileManager.contentsOfDirectory(atPath: path) {

            // Recurse into subdirectories, updating the target directory as well.
            let fileURL = URL(fileURLWithPath: path).appendingPathComponent(filename)
            var isDir: ObjCBool = false
            fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDir)
            guard !isDir.boolValue else {
                try renderPath(fileURL.path, to: targetURL.appendingPathComponent(filename))
                continue
            }

            // Make sure this path exists so we can write to it.
            try fileManager.createDirectory(at: targetURL, withIntermediateDirectories: true, attributes: nil)

            // Handle the file, transforming it if necessary.
            let ext = filename.split(separator: ".").last!
            switch ext {

            case "less":
                let cssURL = targetURL.appendingPathComponent(filename.replacingOccurrences(of: ".less", with: ".css"))
                try renderLess(from: fileURL, to: cssURL)

            case "md":
                let htmlURL = targetURL.appendingPathComponent(filename.replacingOccurrences(of: ".md", with: ".html"))
                try renderMarkdown(from: fileURL, to: htmlURL, template: "site", context: [:])

            default:
                // Who knows. Copy the file unchanged.
                let src = URL(fileURLWithPath: path).appendingPathComponent(filename)
                let dest = targetURL.appendingPathComponent(filename)
                try fileManager.copyItem(at: src, to: dest)
            }

        }
    }

    func renderLess(from sourceURL: URL, to targetURL: URL) throws {
        let less = try String(contentsOf: sourceURL, encoding: .utf8)
        let css = try lessParser.parse(less)
        try css.write(to: targetURL, atomically: true, encoding: .utf8)
    }

    func renderMarkdown(
        from sourceURL: URL,
        to targetURL: URL,
        template: String,
        context: [String: Any]
    ) throws {
        let bodyMarkdown = try String(contentsOf: sourceURL, encoding: .utf8)
        let bodyResult = mdParser.parse(bodyMarkdown)
        let bodyHTML = bodyResult.html.trimmingCharacters(in: .whitespacesAndNewlines)
        var context = context
        context["site"] = site
        context["body"] = bodyHTML
        context.merge(bodyResult.metadata, uniquingKeysWith: { _, new in new })
        let siteHTML = try templateRenderer.renderTemplate(name: "\(template).html", context: context)
        try siteHTML.write(to: targetURL, atomically: true, encoding: .utf8)
    }
}
