//
//  MarkdownRenderer.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation
import Ink

public final class MarkdownRenderer: Renderer {
    let mdParser = MarkdownParser()

    public func canRenderFile(named filename: String, withExtension ext: String) -> Bool {
        ext == "md"
    }

    /// Parse Markdown and render it as HTML, running it through a Stencil template.
    public func render(fileURL: URL, targetDir: URL, delegate: RendererDelegate) throws {
        let mdFilename = fileURL.lastPathComponent
        let htmlFilename = mdFilename.replacingOccurrences(of: ".md", with: ".html")
        let htmlURL = targetDir.appendingPathComponent(htmlFilename)
        let bodyMarkdown = try String(contentsOf: fileURL, encoding: .utf8)
        let bodyHTML = mdParser.html(from: bodyMarkdown).trimmingCharacters(in: .whitespacesAndNewlines)
        let metadata = try markdownMetadata(from: fileURL)
        let pageHTML = try delegate.renderPage(bodyHTML: bodyHTML, metadata: metadata)
        try pageHTML.write(to: htmlURL, atomically: true, encoding: .utf8)
    }

    func markdownMetadata(from url: URL) throws -> [String: String] {
        let md = try String(contentsOf: url, encoding: .utf8)
        return mdParser.parse(md).metadata
    }
}
