//
//  TemplateContext.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

struct TemplateContext {
    let site: Site
    let page: Page
    let metadata: [String: String]
    let body: String

    var title: String {
        guard !page.title.isEmpty else {
            return site.title
        }

        return "\(site.title): \(page.title)"
    }

    var template: String {
        page.template ?? site.template
    }
}

// MARK: - Dictionary form

extension TemplateContext {
    var dictionary: [String: Any] {
        [
            "site": site,
            "page": page,
            "metadata": metadata,
            "title": title,
            "body": body,
            "styles": site.styles + page.styles,
            "scripts": site.scripts + page.scripts,
        ]
    }
}
