//
//  PageRenderer+Posts.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-22.
//

import Foundation
import Plot

extension PageRenderer: PostsTemplateRenderer {
    func renderArchive(postsByYear: PostsByYear, site: Site) throws -> String {
        let context = SiteContext(site: site, subtitle: "Archive")
        return render(.archive(postsByYear), context: context)
    }

    func renderYearPosts(_ yearPosts: YearPosts, site: Site) throws -> String {
        let context = SiteContext(site: site, subtitle: yearPosts.title)
        return render(.yearPosts(yearPosts), context: context)
    }

    func renderMonthPosts(_ posts: MonthPosts, site: Site) throws -> String {
        let assets = posts.posts.templateAssets
        let context = SiteContext(site: site, subtitle: "\(posts.month.name) \(posts.year)", templateAssets: assets)
        return render(.monthPosts(posts), context: context)
    }

    func renderPost(_ post: Post, site: Site) throws -> String {
        let context = SiteContext(site: site, subtitle: post.title, templateAssets: post.templateAssets)
        return render(.post(post, articleClass: "container"), context: context)
    }

    func renderRecentPosts(_ posts: [Post], site: Site) throws -> String {
        let context = SiteContext(site: site, subtitle: nil, templateAssets: posts.templateAssets)
        return render(.recentPosts(posts), context: context)
    }

    // MARK: - Feeds

    func renderFeedPost(_ post: Post, site: Site) throws -> String {
        let context = SiteContext(site: site, subtitle: post.title, templateAssets: post.templateAssets)
        let url = site.url.appendingPathComponent(post.path)
        // Turn relative URLs into absolute ones.
        return Node.feedPost(post, url: url, styles: context.styles)
            .render(indentedBy: .spaces(2))
            .replacingOccurrences(of: "href=\"/", with: "href=\"\(site.url)/")
            .replacingOccurrences(of: "src=\"/", with: "src=\"\(site.url)/")
    }

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
                    .content(try renderFeedPost(post, site: site))
                )
            })
        ).render(indentedBy: .spaces(2))
    }
}
