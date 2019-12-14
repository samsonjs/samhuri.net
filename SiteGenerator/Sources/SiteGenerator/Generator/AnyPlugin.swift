//
//  AnyPlugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-14.
//

import Foundation

struct AnyPlugin: Plugin {
    private let _setUp: (Site, URL) throws -> Void
    private let _render: (Site, URL, TemplateRenderer) throws -> Void

    init<PluginType: Plugin>(_ plugin: PluginType) {
        self._setUp = { site, sourceURL in
            try plugin.setUp(site: site, sourceURL: sourceURL)
        }
        self._render = { site, targetURL, templateRenderer in
            try plugin.render(site: site, targetURL: targetURL, templateRenderer: templateRenderer)
        }
    }

    func setUp(site: Site, sourceURL: URL) throws {
        try _setUp(site, sourceURL)
    }

    func render(site: Site, targetURL: URL, templateRenderer: TemplateRenderer) throws {
        try _render(site, targetURL, templateRenderer)
    }
}
