//
//  Generator.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation
import PathKit
import Stencil

public final class Generator {
    private let fileManager: FileManager = .default

    public let site: Site
    public let sourceURL: URL

    private let renderer: Environment

    public init(sourceURL: URL) throws {
        let publicURL = sourceURL.appendingPathComponent("public")
        self.renderer = Environment(loader: FileSystemLoader(paths: [Path(publicURL.path)]))
        let siteURL = sourceURL.appendingPathComponent("site.json")
        self.site = try Site.decode(from: siteURL)
        self.sourceURL = sourceURL
    }

    public func generate(targetURL: URL) throws {
        try fileManager.createDirectory(at: targetURL, withIntermediateDirectories: true, attributes: nil)
        let indexHTML = try renderer.renderTemplate(name: "index.html", context: ["site": site])
        let indexURL = targetURL.appendingPathComponent("index.html")
        try indexHTML.write(to: indexURL, atomically: true, encoding: .utf8)
    }
}
