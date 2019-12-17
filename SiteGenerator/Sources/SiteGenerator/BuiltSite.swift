//
//  BuiltSite.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-15.
//

import Foundation

public struct BuiltSite {
    public let site: Site
    public let plugins: [Plugin]
    public let renderers: [Renderer]

    init(site: Site, plugins: [Plugin], renderers: [Renderer]) {
        self.site = site
        self.plugins = plugins
        self.renderers = renderers
    }
}
