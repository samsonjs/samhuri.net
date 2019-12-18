//
//  SiteContext.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation
import SiteGenerator

struct SiteContext {
    let site: Site

    init(site: Site) {
        self.site = site
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
