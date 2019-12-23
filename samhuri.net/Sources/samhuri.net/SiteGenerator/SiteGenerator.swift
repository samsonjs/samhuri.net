//
//  samhuri.net.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

final class SiteGenerator {
    // Dependencies
    let fileManager: FileManager = .default

    // Site properties
    let site: Site
    let sourceURL: URL

    let ignoredFilenames = [".DS_Store", ".gitkeep"]

    init(sourceURL: URL, site: Site) throws {
        self.site = site
        self.sourceURL = sourceURL

        try initializePlugins()
    }

    private func initializePlugins() throws {
        for plugin in site.plugins {
            try plugin.setUp(site: site, sourceURL: sourceURL)
        }
    }

    func generate(targetURL: URL) throws {
        for plugin in site.plugins {
            try plugin.render(site: site, targetURL: targetURL)
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
            _ = fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDir)
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

    func renderOrCopyFile(url sourceURL: URL, targetDir: URL) throws {
        let filename = sourceURL.lastPathComponent
        let targetURL = targetDir.appendingPathComponent(filename)

        // Clear the way so write operations don't fail later on.
        if fileManager.fileExists(atPath: targetURL.path) {
            try fileManager.removeItem(at: targetURL)
        }

        let ext = String(filename.split(separator: ".").last!)
        for renderer in site.renderers {
            if renderer.canRenderFile(named: filename, withExtension: ext) {
                try renderer.render(site: site, fileURL: sourceURL, targetDir: targetDir)
                return
            }
        }

        // Not handled by any renderer. Copy the file unchanged.
        try fileManager.copyItem(at: sourceURL, to: targetURL)
    }
}
