//
//  MarkdownRenderer.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation
import Ink

final class MarkdownRenderer: Renderer {
    let fileManager: FileManager = .default
    let fileWriter: FileWriting
    let markdownParser = MarkdownParser()
    let pageRenderer: MarkdownPageRenderer

    init(pageRenderer: MarkdownPageRenderer, fileWriter: FileWriting = FileWriter()) {
        self.pageRenderer = pageRenderer
        self.fileWriter = fileWriter
    }

    func canRenderFile(named filename: String, withExtension ext: String) -> Bool {
        ext == "md"
    }

    /// Parse Markdown and render it as HTML, running it through a Stencil template.
    func render(site: Site, fileURL: URL, targetDir: URL) throws {
        let bodyMarkdown = try String(contentsOf: fileURL, encoding: .utf8)
        let bodyHTML = markdownParser.html(from: bodyMarkdown).trimmingCharacters(in: .whitespacesAndNewlines)
        let metadata = try markdownMetadata(from: fileURL)
        let pageHTML = try pageRenderer.renderPage(site: site, bodyHTML: bodyHTML, metadata: metadata)

        let mdFilename = fileURL.lastPathComponent
        let htmlPath: String
        if metadata["Hide extension"]?.lowercased() == "no" || mdFilename == "index.md" {
            htmlPath = mdFilename.replacingOccurrences(of: ".md", with: ".html")
        }
        else {
            htmlPath = mdFilename.replacingOccurrences(of: ".md", with: "/index.html")
        }
        let htmlURL = targetDir.appendingPathComponent(htmlPath)
        try fileWriter.write(string: pageHTML, to: htmlURL)
    }

    func markdownMetadata(from url: URL) throws -> [String: String] {
        let md = try String(contentsOf: url, encoding: .utf8)
        return markdownParser.parse(md).metadata
    }
}
