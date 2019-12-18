//
//  PageContext.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation
import SiteGenerator

struct PageContext {
    let site: Site
    let body: String
    let page: Page
    let metadata: [String: String]
}

extension PageContext {
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
