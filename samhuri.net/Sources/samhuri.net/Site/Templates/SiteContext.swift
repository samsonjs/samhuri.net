//
//  SiteContext.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

struct SiteContext: TemplateContext {
    let site: Site
    let canonicalURL: URL
    let subtitle: String?
    let description: String
    let pageType: String
    let templateAssets: TemplateAssets

    init(
        site: Site,
        canonicalURL: URL,
        subtitle: String? = nil,
        description: String? = nil,
        pageType: String? = nil,
        templateAssets: TemplateAssets = .empty()
    ) {
        self.site = site
        self.canonicalURL = canonicalURL
        self.subtitle = subtitle
        self.description = description ?? site.description
        self.pageType = pageType ?? "website"

        self.templateAssets = templateAssets
    }

    var title: String {
        guard let subtitle = subtitle else {
            return site.title
        }

        return "\(site.title): \(subtitle)"
    }
}
