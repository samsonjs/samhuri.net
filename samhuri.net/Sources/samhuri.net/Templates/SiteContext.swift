//
//  SiteContext.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation
import SiteGenerator

struct SiteContext: TemplateContext {
    let site: Site
    let subtitle: String?

    init(site: Site, subtitle: String? = nil) {
        self.site = site
        self.subtitle = subtitle
    }

    var title: String {
        guard let subtitle = subtitle else {
            return site.title
        }

        return "\(site.title): \(subtitle)"
    }

    var styles: [URL] {
        site.styles.map { style in
            style.hasPrefix("http") ? URL(string: style)! : url(for: style)
        }
    }

    var scripts: [URL] {
        site.scripts.map { script in
            script.hasPrefix("http") ? URL(string: script)! : url(for: script)
        }
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
