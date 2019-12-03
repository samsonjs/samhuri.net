//
//  Generator.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation
import PathKit
import Stencil

public final class Generator: PluginDelegate, RendererDelegate {
    // Dependencies
    let fileManager: FileManager = .default
    let templateRenderer: Environment

    // Site properties
    let site: Site
    let sourceURL: URL
    let plugins: [Plugin]
    let renderers: [Renderer]

    public init(sourceURL: URL, plugins: [Plugin], renderers: [Renderer]) throws {
        let templatesURL = sourceURL.appendingPathComponent("templates")
        let templatesPath = Path(templatesURL.path)
        let loader = FileSystemLoader(paths: [templatesPath])
        self.templateRenderer = Environment(loader: loader)

        let siteURL = sourceURL.appendingPathComponent("site.json")
        self.site = try Site.decode(from: siteURL)
        self.sourceURL = sourceURL
        self.plugins = plugins
        self.renderers = renderers

        for plugin in plugins {
            try plugin.setUp(sourceURL: sourceURL)
        }
    }

    public func generate(targetURL: URL) throws {
        for plugin in plugins {
            try plugin.render(targetURL: targetURL, delegate: self)
        }

        let publicURL = sourceURL.appendingPathComponent("public")
        try renderPath(publicURL.path, to: targetURL)
    }

    // Recursively copy or render every file in the given path.
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

            // Processes the file, transforming it if necessary.
            try renderOrCopyFile(url: fileURL, targetDir: targetURL)
        }
    }

    func renderOrCopyFile(url fileURL: URL, targetDir: URL) throws {
        let filename = fileURL.lastPathComponent
        guard filename != ".DS_Store", filename != ".gitkeep" else {
            print("Ignoring hidden file \(filename)")
            return
        }

        let ext = String(filename.split(separator: ".").last!)
        for renderer in renderers {
            if renderer.canRenderFile(named: filename, withExtension: ext) {
                try renderer.render(fileURL: fileURL, targetDir: targetDir, delegate: self)
                return
            }
        }

        // Not handled by any renderer. Copy the file unchanged.
        let dest = targetDir.appendingPathComponent(filename)
        try fileManager.copyItem(at: fileURL, to: dest)
    }

    // MARK: - PluginDelegate and RendererDelegate

    public func renderPage(bodyHTML: String, metadata: [String: String]) throws -> String {
        let page = Page(metadata: metadata)
        let context = PageContext(site: site, body: bodyHTML, page: page, metadata: metadata)
        let pageHTML = try templateRenderer.renderTemplate(name: "\(context.template).html", context: context.dictionary)
        return pageHTML
    }

    public func renderTemplate(name: String?, context: [String: Any]) throws -> String {
        let siteContext = SiteContext(site: site, template: name)
        let contextDict = siteContext.dictionary.merging(context, uniquingKeysWith: { _, new in new })
        print("Rendering \(siteContext.template) with context \(contextDict)")
        return try templateRenderer.renderTemplate(name: "\(siteContext.template).html", context: contextDict)
    }
}
