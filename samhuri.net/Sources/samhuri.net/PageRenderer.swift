//
//  PageRenderer.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-17.
//

import Foundation
import Plot

final class PageRenderer {
    func render(_ body: Node<HTML.BodyContext>, context: TemplateContext) -> String {
        Template.site(body: body, context: context).render(indentedBy: .spaces(2))
    }
}

extension PageRenderer: MarkdownPageRenderer {
    func renderPage(site: Site, bodyHTML: String, metadata: [String: String]) throws -> String {
        let pageTitle = metadata["Title"]
        let context = SiteContext(site: site, subtitle: pageTitle, templateAssets: .none())
        return render(.page(title: pageTitle ?? "", bodyHTML: bodyHTML), context: context)
    }
}
