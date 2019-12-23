//
//  BuiltSite.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-15.
//

import Foundation

struct BuiltSite {
    let site: Site
    let plugins: [Plugin]
    let renderers: [Renderer]

    init(site: Site, plugins: [Plugin], renderers: [Renderer]) {
        self.site = site
        self.plugins = plugins
        self.renderers = renderers
    }
}
