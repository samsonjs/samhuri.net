//
//  PageRenderer.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-17.
//

import Foundation
import Plot
import SiteGenerator

#warning("Deprecated imports")
import PathKit
import Stencil

final class PageRenderer {
    @available(*, deprecated)
    let stencil: Environment

    init(templatesURL: URL) {
        let templatesPath = Path(templatesURL.path)
        let loader = FileSystemLoader(paths: [templatesPath])
        self.stencil = Environment(loader: loader)
    }

    func render(_ body: Node<HTML.BodyContext>, context: TemplateContext) -> String {
        Template.site(body: body, context: context).render(indentedBy: .spaces(2))
    }
}

extension PageRenderer: MarkdownPageRenderer {
    func renderPage(site: Site, bodyHTML: String, metadata: [String: String]) throws -> String {
        let pageTitle = metadata["Title", default: ""]
        let context = SiteContext(site: site, subtitle: pageTitle, templateAssets: .none())
        return render(.page(title: pageTitle, bodyHTML: bodyHTML), context: context)
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
        let siteContext = SiteContext(site: site, subtitle: nil, templateAssets: .none())
        let contextDict = siteContext.dictionary.merging(context, uniquingKeysWith: { _, new in new })
        return try stencil.renderTemplate(name: template.htmlFilename, context: contextDict)
    }
}

extension PageRenderer: ProjectsTemplateRenderer {
    func renderProjects(_ projects: [Project], site: Site, assets: TemplateAssets) throws -> String {
        let context = SiteContext(site: site, subtitle: "Projects", templateAssets: assets)
        return render(.projects(projects), context: context)
    }

    func renderProject(_ project: Project, site: Site, assets: TemplateAssets) throws -> String {
        let projectContext = ProjectContext(project: project, site: site, templateAssets: assets)
        let context = SiteContext(site: site, subtitle: project.title, templateAssets: assets)
        return render(.project(projectContext), context: context)
    }
}
