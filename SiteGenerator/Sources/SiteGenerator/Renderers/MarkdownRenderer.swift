//
//  MarkdownRenderer.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation
import Ink

public final class MarkdownRenderer: Renderer {
    let fileManager: FileManager = .default
    let markdownParser = MarkdownParser()

    public func canRenderFile(named filename: String, withExtension ext: String) -> Bool {
        ext == "md"
    }

    /// Parse Markdown and render it as HTML, running it through a Stencil template.
    public func render(fileURL: URL, targetDir: URL, templateRenderer: TemplateRenderer) throws {
        let bodyMarkdown = try String(contentsOf: fileURL, encoding: .utf8)
        let bodyHTML = markdownParser.html(from: bodyMarkdown).trimmingCharacters(in: .whitespacesAndNewlines)
        let metadata = try markdownMetadata(from: fileURL)
        let pageHTML = try templateRenderer.renderPage(bodyHTML: bodyHTML, metadata: metadata)

        let mdFilename = fileURL.lastPathComponent
        let htmlPath: String
        if metadata["Hide extension"]?.lowercased() == "no" || mdFilename == "index.md" {
            htmlPath = mdFilename.replacingOccurrences(of: ".md", with: ".html")
        }
        else {
            htmlPath = mdFilename.replacingOccurrences(of: ".md", with: "/index.html")
        }
        let htmlURL = targetDir.appendingPathComponent(htmlPath)
        try fileManager.createDirectory(at: htmlURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try pageHTML.write(to: htmlURL, atomically: true, encoding: .utf8)
    }

    func markdownMetadata(from url: URL) throws -> [String: String] {
        let md = try String(contentsOf: url, encoding: .utf8)
        return markdownParser.parse(md).metadata
    }
}
