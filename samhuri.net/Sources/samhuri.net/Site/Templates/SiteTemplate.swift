//
//  SiteTemplate.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-19.
//

import Foundation
import Plot

private extension Node where Context == HTML.DocumentContext {
    /// Add a `<head>` HTML element within the current context, which
    /// contains non-visual elements, such as stylesheets and metadata.
    /// - parameter nodes: The element's attributes and child elements.
    static func head(_ nodes: [Node<HTML.HeadContext>]) -> Node {
        .element(named: "head", nodes: nodes)
    }
}

enum Template {
    static func site<Context: TemplateContext>(body: Node<HTML.BodyContext>, context: Context) -> HTML {
        // Broken up to fix a build error because Swift can't type-check the varargs version.
        let headNodes: [Node<HTML.HeadContext>] = [
            .encoding(.utf8),
            .title(context.title),
            .description(context.description),
            .siteName(context.site.title),
            .url(context.canonicalURL),
            .meta(.property("og:image"), .content(context.site.imageURL?.absoluteString ?? "")),
            .meta(.property("og:type"), .content(context.pageType)),
            .meta(.property("article:author"), .content(context.site.author)),
            .meta(.name("twitter:card"), .content("summary")),
            .rssFeedLink(context.url(for: "feed.xml"), title: context.site.title),
            .jsonFeedLink(context.url(for: "feed.json"), title: context.site.title),
            .meta(.name("fediverse:creator"), .content("@sjs@techhub.social")),
            .link(.rel(.author), .type("text/plain"), .href(context.url(for: "humans.txt"))),
            .link(.rel(.icon), .type("image/png"), .href(context.imageURL("favicon-32x32.png"))),
            .link(.rel(.shortcutIcon), .href(context.imageURL("favicon.icon"))),
            .appleTouchIcon(context.imageURL("apple-touch-icon.png")),
            .safariPinnedTabIcon(context.imageURL("safari-pinned-tab.svg"), color: "#aa0000"),
            .link(.attribute(named: "rel", value: "manifest"), .href(context.imageURL("manifest.json"))),
            .meta(.name("msapplication-config"), .content(context.imageURL("browserconfig.xml").absoluteString)),
            .meta(.name("theme-color"), .content("#121212")), // matches header
            .meta(.name("viewport"), .content("width=device-width, initial-scale=1.0, viewport-fit=cover")),
            .link(.rel(.dnsPrefetch), .href("https://gist.github.com")),
            .group(context.styles.map { url in
                    .link(.rel(.stylesheet), .type("text/css"), .href(url))
            }),
        ]
        return HTML(
            .lang(.english),
            .comment("meow"),
            .head(headNodes),
            .body(
                .header(.class("primary"),
                    .div(.class("title"),
                         .h1(.a(.href(context.site.url), .text(context.site.title))),
                         .br(),
                         .h4(.text("By "), .a(.href(context.url(for: "about")), .text(context.site.author)))
                    ),
                    .nav(.class("remote"),
                        .ul(
                            .li(.class("mastodon"),
                                .a(
                                    .attribute(named: "rel", value: "me"),
                                    .attribute(named: "aria-label", value: "Mastodon"),
                                    .href("https://techhub.social/@sjs"),
                                    Icons.mastodon()
                                )
                            ),
                            .li(.class("github"),
                                .a(
                                    .attribute(named: "aria-label", value: "GitHub"),
                                    .href("https://github.com/samsonjs"),
                                    Icons.github()
                                )
                            ),
                            .li(.class("rss"),
                                .a(
                                    .attribute(named: "aria-label", value: "RSS"),
                                    .href(context.url(for: "feed.xml")),
                                    Icons.rss()
                                )
                            )
                        )
                    ),
                    .nav(.class("local"),
                        .ul(
                            .li(.a(.href(context.url(for: "about")), "About")),
                            .li(.a(.href(context.url(for: "posts")), "Archive")),
                            .li(.a(.href(context.url(for: "projects")), "Projects"))
                        )
                    ),
                    .div(.class("clearfix"))
                ),

                body,

                .footer(
                    "© 2006 - \(context.currentYear)",
                    .a(.href(context.url(for: "about")), .text(context.site.author))
                ),

                .group(context.scripts.map { script in
                    .script(.attribute(named: "defer"), .src(script))
                })
            )
        )
    }
}
