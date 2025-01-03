//
//  MarkdownRenderer.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation
import Ink

final class MarkdownRenderer: Renderer {
    let fileWriter: FileWriting
    let markdownParser = MarkdownParser()
    let pageRenderer: PageRendering

    init(pageRenderer: PageRendering, fileWriter: FileWriting = FileWriter()) {
        self.pageRenderer = pageRenderer
        self.fileWriter = fileWriter
    }

    func canRenderFile(named filename: String, withExtension ext: String?) -> Bool {
        ext == "md"
    }

    /// Parse Markdown and render it as HTML, running it through a Stencil template.
    func render(site: Site, fileURL: URL, targetDir: URL) throws {
        let metadata = try markdownMetadata(from: fileURL)
        let mdFilename = fileURL.lastPathComponent
        let showExtension = mdFilename == "index.md" || metadata["Show extension"]?.lowercased() == "yes"
        let htmlPath: String = if showExtension {
            mdFilename.replacingOccurrences(of: ".md", with: ".html")
        }
        else {
            mdFilename.replacingOccurrences(of: ".md", with: "/index.html")
        }
        let bodyMarkdown = try String(contentsOf: fileURL)
        let bodyHTML = markdownParser.html(from: bodyMarkdown).trimmingCharacters(in: .whitespacesAndNewlines)
        let url = site.url.appending(path: htmlPath.replacingOccurrences(of: "/index.html", with: ""))
        let pageHTML = try pageRenderer.renderPage(
            site: site,
            url: url,
            bodyHTML: bodyHTML,
            metadata: metadata
        )

        let htmlURL = targetDir.appendingPathComponent(htmlPath)
        try fileWriter.write(string: pageHTML, to: htmlURL)
    }

    func markdownMetadata(from url: URL) throws -> [String: String] {
        let md = try String(contentsOf: url)
        return markdownParser.parse(md).metadata
    }
}
