//
//  SiteTemplate.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-19.
//

import Foundation
import Plot

enum Template {
    static func site(body: Node<HTML.BodyContext>, context: TemplateContext) -> HTML {
        HTML(
            .lang(.english),
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
                .link(.rel(.dnsPrefetch), .href("https://gist.github.com")),
                .group(context.styles.map { url in
                    .link(.rel(.stylesheet), .type("text/css"), .href(url))
                })
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
                            .li(.class("twitter"), .a(.href("https://twitter.com/_sjs"), .i(.class("fab fa-twitter")))),
                            .li(.class("mastodon"), .a(.attribute(named: "rel", value: "me"), .href("https://techhub.social/@sjs"), .i(.class("fab fa-mastodon")))),
                            .li(.class("github"), .a(.href("https://github.com/samsonjs"), .i(.class("fab fa-github")))),
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

                .group(context.scripts.map { script in
                    .script(.attribute(named: "defer"), .src(script))
                }),
                .script(.src("https://use.typekit.net/tcm1whv.js"), .attribute(named: "crossorigin", value: "anonymous")),
                .script("try{Typekit.load({ async: true });}catch(e){}")
            )
        )
    }
}
