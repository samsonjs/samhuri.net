//
//  SiteContext.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

struct SiteContext: TemplateContext {
    let site: Site
    let subtitle: String?
    let templateAssets: TemplateAssets

    init(site: Site, subtitle: String? = nil, templateAssets: TemplateAssets = .empty()) {
        self.site = site
        self.subtitle = subtitle
        self.templateAssets = templateAssets
    }

    var title: String {
        guard let subtitle = subtitle else {
            return site.title
        }

        return "\(site.title): \(subtitle)"
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
