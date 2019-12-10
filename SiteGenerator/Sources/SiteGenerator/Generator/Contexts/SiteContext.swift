//
//  SiteContext.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

struct SiteContext {
    let site: Site
    let template: String

    init(site: Site, template: String? = nil) {
        self.site = site
        self.template = template ?? site.template
    }
}

extension SiteContext {
    var dictionary: [String: Any] {
        [
            "site": site,
            "title": site.title,
            "styles": site.styles,
            "scripts": site.scripts,
            "currentYear": Date().year,
        ]
    }
}
