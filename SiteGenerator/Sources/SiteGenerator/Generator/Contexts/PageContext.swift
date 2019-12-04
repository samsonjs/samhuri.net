//
//  File.swift
//  
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

struct PageContext {
    let site: Site
    let body: String
    let page: Page
    let metadata: [String: String]

    var title: String {
        guard !page.title.isEmpty else {
            return site.title
        }

        return "\(site.title): \(page.title)"
    }
}

extension PageContext: TemplateContext {
    var template: String {
        page.template ?? site.template
    }

    var dictionary: [String: Any] {
        [
            "site": site,
            "title": title,
            "body": body,
            "page": page,
            "metadata": metadata,
            "styles": site.styles + page.styles,
            "scripts": site.scripts + page.scripts,
            "currentYear": Date().year,
        ]
    }
}
