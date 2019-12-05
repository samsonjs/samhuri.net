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
}

extension PageContext: TemplateContext {
    var template: String {
        page.template ?? site.template
    }

    var dictionary: [String: Any] {
        [
            "site": site,
            "body": body,
            "page": page,
            "metadata": metadata,
            "styles": site.styles + page.styles,
            "scripts": site.scripts + page.scripts,
            "currentYear": Date().year,
        ]
    }
}
