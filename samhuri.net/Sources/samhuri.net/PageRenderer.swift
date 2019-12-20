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

    func siteTemplate(body: Node<HTML.BodyContext>, context: TemplateContext) -> HTML {
        HTML(.lang("en"),
             .comment("meow"),
            .head(
                .encoding(.utf8),
                .viewport(.accordingToDevice),
                .title(context.title),
                .siteName(context.site.title),
                .url(context.site.url),
                .rssFeedLink(context.url(for: "feed.xml"), title: context.site.title),
                .jsonFeedLink(context.url(for: "feed.json"), title: context.site.title),
                .link(.rel(.author), .type("text/plain"), .href(context.url(for: "humans.txt"))),
                .link(.rel(.icon), .type("image/png"), .href(context.imageURL("favicon-32x32.png"))),
                .link(.rel(.shortcutIcon), .href(context.imageURL("favicon.icon"))),
                .appleTouchIcon(context.imageURL("apple-touch-icon.png")),
                .safariPinnedTabIcon(context.imageURL("safari-pinned-tab.svg"), color: "#aa0000"),
                .link(.attribute(named: "rel", value: "manifest"), .href(context.imageURL("manifest.json"))),
                .meta(.name("msapplication-config"), .content(context.imageURL("browserconfig.xml").absoluteString)),
                .meta(.name("theme-color"), .content("#ffffff")),
                .link(.rel(.dnsPrefetch), .href("https://use.typekit.net")),
                .link(.rel(.dnsPrefetch), .href("https://netdna.bootstrapcdn.com")),
                .link(.rel(.dnsPrefetch), .href("https://gist.github.com"))
            ),
            .body(
                .header(.class("primary"),
                    .div(.class("title"),
                         .h1(.a(.href(context.site.url), .text(context.site.title))),
                         .br(),
                         .h4(.text("By "), .a(.href(context.url(for: "about")), .text(context.site.author)))
                    ),
                    .nav(
                        .ul(
                            .li(.a(.href(context.url(for: "about")), "About")),
                            .li(.a(.href(context.url(for: "posts")), "Archive")),
                            .li(.a(.href(context.url(for: "projects")), "Projects")),
                            .li(.class("twitter"), .a(.href("https://twitter.com/_sjs"), .i(.class("fa fa-twitter")))),
                            .li(.class("github"), .a(.href("https://github.com/samsonjs"), .i(.class("fa fa-github")))),
                            .li(.class("email"), .a(.href("mailto:\(context.site.email)"), .i(.class("fa fa-envelope")))),
                            .li(.class("rss"), .a(.href(context.url(for: "feed.xml")), .i(.class("fa fa-rss"))))
                        )
                    ),
                    .div(.class("clearfix"))
                ),
                body,
                .footer(.class("container"),
                    "© 2006 - \(context.currentYear)",
                    .a(.href(context.url(for: "about")), .text(context.site.author))
                ),
                .asyncStylesheetLinks(context.styles),
                .group(context.scripts.map { script in
                    .script(.attribute(named: "defer"), .src(script))
                }),
                .script(.src("https://use.typekit.net/tcm1whv.js"), .attribute(named: "crossorigin", value: "anonymous")),
                .script("try{Typekit.load({ async: true });}catch(e){}")
            )
        )
    }
}

extension PageRenderer: MarkdownPageRenderer {
    func renderPage(site: Site, bodyHTML: String, metadata: [String: String]) throws -> String {
        let page = Page(metadata: metadata)
        let context = PageContext(site: site, body: bodyHTML, page: page, metadata: metadata)
        let body: Node<HTML.BodyContext> = .group([
            .article(.class("container"),
                .h1(.text(page.title)),
                .raw(bodyHTML)
            ),
            .div(.class("row clearfix"),
                .p(.class("fin"), .i(.class("fa fa-code")))
            )
        ])
        return siteTemplate(body: body, context: context).render(indentedBy: .spaces(2))
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
