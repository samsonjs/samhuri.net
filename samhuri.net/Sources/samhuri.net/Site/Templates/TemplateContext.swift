//
//  TemplateContext.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-18.
//

import Foundation

protocol TemplateContext {
    // Concrete requirements, must be implemented

    var site: Site { get }
    var title: String { get }
    var templateAssets: TemplateAssets { get }

    // These all have default implementations

    var styles: [URL] { get }
    var scripts: [URL] { get }

    var currentYear: Int { get }

    func url(for path: String) -> URL
    func imageURL(_ filename: String) -> URL
    func scriptURL(_ filename: String) -> URL
    func styleURL(_ filename: String) -> URL
}

extension TemplateContext {
    var scripts: [URL] {
        let allScripts = site.scripts + templateAssets.scripts
        return allScripts.map { script in
            script.url(dir: scriptDir)
        }
    }

    var styles: [URL] {
        let allStyles = site.styles + templateAssets.styles
        return allStyles.map { style in
            style.url(dir: styleDir)
        }
    }

    var currentYear: Int {
        Date().year
    }

    func url(for path: String) -> URL {
        site.url.appendingPathComponent(path)
    }

    func imageURL(_ filename: String) -> URL {
        site.url
            .appendingPathComponent("images")
            .appendingPathComponent(filename)
    }

    func scriptURL(_ filename: String) -> URL {
        scriptDir.appendingPathComponent(filename)
    }

    func styleURL(_ filename: String) -> URL {
        styleDir.appendingPathComponent(filename)
    }
}

private extension TemplateContext {
    var scriptDir: URL {
        site.url.appendingPathComponent("js")
    }

    var styleDir: URL {
        site.url.appendingPathComponent("css")
    }
}
