//
//  SiteTemplateRenderer.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation
import PathKit
import Stencil

final class SiteTemplateRenderer: TemplateRenderer {
    let site: Site
    let stencil: Environment

    init(site: Site, templatesURL: URL) {
        self.site = site
        let templatesPath = Path(templatesURL.path)
        let loader = FileSystemLoader(paths: [templatesPath])
        self.stencil = Environment(loader: loader)
    }

    func renderPage(bodyHTML: String, metadata: [String: String]) throws -> String {
        let page = Page(metadata: metadata)
        let context = PageContext(site: site, body: bodyHTML, page: page, metadata: metadata)
        let pageHTML = try stencil.renderTemplate(name: "\(context.template).html", context: context.dictionary)
        return pageHTML
    }

    func renderTemplate(name: String?, context: [String: Any]) throws -> String {
        let siteContext = SiteContext(site: site, template: name)
        let contextDict = siteContext.dictionary.merging(context, uniquingKeysWith: { _, new in new })
        return try stencil.renderTemplate(name: "\(siteContext.template).html", context: contextDict)
    }
}
