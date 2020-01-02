//
//  PageRenderer+RSSFeed.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2020-01-01.
//

import Foundation
import Plot

extension PageRenderer: RSSFeedRendering {
    func renderRSSFeed(posts: [Post], feedURL: URL, site: Site) throws -> String {
        try RSS(
            .title(site.title),
            .if(site.description != nil, .description(site.description!)),
            .link(site.url),
            .pubDate(posts[0].date),
            .atomLink(feedURL),
            .group(posts.map { post in
                let url = site.url.appendingPathComponent(post.path)
                return .item(
                    .title(post.isLink ? "→ \(post.title)" : post.title),
                    .pubDate(post.date),
                    .element(named: "author", text: post.author),
                    .link(url),
                    .guid(.text(url.absoluteString), .isPermaLink(true)),
                    .content(try renderJSONFeedPost(post, site: site))
                )
            })
        ).render(indentedBy: .spaces(2))
    }
}
