//
//  PageRenderer.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-17.
//

import Foundation
import PathKit
import SiteGenerator
import Stencil

final class PageRenderer {
    @available(*, deprecated)
    let stencil: Environment

    init(templatesURL: URL) {
        let templatesPath = Path(templatesURL.path)
        let loader = FileSystemLoader(paths: [templatesPath])
        self.stencil = Environment(loader: loader)
    }
}

extension PageRenderer: MarkdownPageRenderer {
    func renderPage(site: Site, bodyHTML: String, metadata: [String: String]) throws -> String {
        let page = Page(metadata: metadata)
        let context = PageContext(site: site, body: bodyHTML, page: page, metadata: metadata)
        let pageHTML = try stencil.renderTemplate(name: "page.html", context: context.dictionary)
        return pageHTML
    }
}

extension PostTemplate {
    @available(*, deprecated)
    var htmlFilename: String {
        switch self {
        case .archive:
            return "posts-archive.html"
        case .feedPost:
            return "feed-post.html"
        case .monthPosts:
            return "posts-month.html"
        case .post:
            return "post.html"
        case .recentPosts:
            return "recent-posts.html"
        case .rssFeed:
            return "feed.xml"
        case .yearPosts:
            return "posts-year.html"
        }
    }
}

extension PageRenderer: PostsTemplateRenderer {
    func renderTemplate(_ template: PostTemplate, site: Site, context: [String : Any]) throws -> String {
        let siteContext = SiteContext(site: site)
        let contextDict = siteContext.dictionary.merging(context, uniquingKeysWith: { _, new in new })
        return try stencil.renderTemplate(name: template.htmlFilename, context: contextDict)
    }
}

extension ProjectTemplate {
    @available(*, deprecated)
    var htmlFilename: String {
        switch self {
        case .project:
            return "project.html"
        case .projects:
            return "projects.html"
        }
    }
}

extension PageRenderer: ProjectsTemplateRenderer {
    func renderTemplate(_ template: ProjectTemplate, site: Site, context: [String : Any]) throws -> String {
        let siteContext = SiteContext(site: site)
        let contextDict = siteContext.dictionary.merging(context, uniquingKeysWith: { _, new in new })
        return try stencil.renderTemplate(name: template.htmlFilename, context: contextDict)
    }
}

extension Date {
    var year: Int {
        Calendar.current.dateComponents([.year], from: self).year!
    }
}
