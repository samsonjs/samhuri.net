//
//  PageContext.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation
import SiteGenerator

struct PageContext: TemplateContext {
    let site: Site
    @available(*, deprecated) let body: String
    let page: Page
    @available(*, deprecated) let metadata: [String: String]

    var title: String {
        "\(site.title): \(page.title)"
    }

    var templateAssets: TemplateAssets {
        page.templateAssets
    }
}

extension PageContext {
    @available(*, deprecated)
    var dictionary: [String: Any] {
        [
            "site": site,
            "body": body,
            "page": page,
            "metadata": metadata,
            "styles": site.styles + templateAssets.styles,
            "scripts": site.scripts + templateAssets.scripts,
            "currentYear": Date().year,
        ]
    }
}
