//
//  SiteGenerator.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

public final class SiteGenerator {
    // Dependencies
    let fileManager: FileManager = .default
    let templateRenderer: TemplateRenderer

    // Site properties
    let site: Site
    let sourceURL: URL
    var plugins: [Plugin] = []
    let renderers: [Renderer]

    let ignoredFilenames = [".DS_Store", ".gitkeep"]

    public init(sourceURL: URL, siteURLOverride: URL? = nil, renderers: [Renderer]) throws {
        let siteURL = sourceURL.appendingPathComponent("site.json")
        var site = try Site.decode(from: siteURL)
        if let url = siteURLOverride {
            print("Overriding site URL \(site.url) with \(url)")
            site.url = url
        }

        let templatesURL = sourceURL.appendingPathComponent("templates")
        self.templateRenderer = SiteTemplateRenderer(site: site, templatesURL: templatesURL)

        self.site = site
        self.sourceURL = sourceURL
        self.renderers = renderers

        try initializePlugins()
    }

    private func initializePlugins() throws {
        plugins = site.plugins.map { (sitePlugin, options) in
            switch sitePlugin {
            case .projects:
                return ProjectsPlugin(options: options)
            case .posts:
                return PostsPlugin(options: options)
            }
        }
        for plugin in plugins {
            try plugin.setUp(site: site, sourceURL: sourceURL)
        }
    }

    public func generate(targetURL: URL) throws {
        for plugin in plugins {
            try plugin.render(site: site, targetURL: targetURL, templateRenderer: templateRenderer)
        }

        let publicURL = sourceURL.appendingPathComponent("public")
        try renderPath(publicURL.path, to: targetURL)
    }

    // Recursively copy or render every file in the given path.
    func renderPath(_ path: String, to targetURL: URL) throws {
        for filename in try fileManager.contentsOfDirectory(atPath: path) {
            guard !ignoredFilenames.contains(filename) else {
                continue
            }

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

            // Process the file, transforming it if necessary.
            try renderOrCopyFile(url: fileURL, targetDir: targetURL)
        }
    }

    func renderOrCopyFile(url fileURL: URL, targetDir: URL) throws {
        let filename = fileURL.lastPathComponent
        let ext = String(filename.split(separator: ".").last!)
        for renderer in renderers {
            if renderer.canRenderFile(named: filename, withExtension: ext) {
                try renderer.render(fileURL: fileURL, targetDir: targetDir, templateRenderer: templateRenderer)
                return
            }
        }

        // Not handled by any renderer. Copy the file unchanged.
        let dest = targetDir.appendingPathComponent(filename)
        try fileManager.copyItem(at: fileURL, to: dest)
    }
}
