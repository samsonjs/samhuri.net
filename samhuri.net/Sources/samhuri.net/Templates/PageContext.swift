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

    var styles: [URL] {
        (site.styles + page.styles).map { style in
            style.hasPrefix("http") ? URL(string: style)! : url(for: style)
        }
    }

    var scripts: [URL] {
        (site.scripts + page.scripts).map { script in
            script.hasPrefix("http") ? URL(string: script)! : url(for: script)
        }
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
            "styles": site.styles + page.styles,
            "scripts": site.scripts + page.scripts,
            "currentYear": Date().year,
        ]
    }
}
