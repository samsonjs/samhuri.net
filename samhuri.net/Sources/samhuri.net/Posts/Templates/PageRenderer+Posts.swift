//
//  PageRenderer+Posts.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-22.
//

import Foundation
import Plot

extension PageRenderer: PostsRendering {
    func renderArchive(postsByYear: PostsByYear, site: Site, path: String) throws -> String {
        let context = SiteContext(
            site: site,
            canonicalURL: site.url.appending(path: path),
            subtitle: "Archive",
            description: "Archive of all posts"
        )
        return render(.archive(postsByYear), context: context)
    }

    func renderYearPosts(_ yearPosts: YearPosts, site: Site, path: String) throws -> String {
        let context = SiteContext(
            site: site,
            canonicalURL: site.url.appending(path: path),
            subtitle: yearPosts.title,
            description: "Archive of all posts from \(yearPosts.year)",
            pageType: "article"
        )
        return render(.yearPosts(yearPosts), context: context)
    }

    func renderMonthPosts(_ posts: MonthPosts, site: Site, path: String) throws -> String {
        let subtitle = "\(posts.month.name) \(posts.year)"
        let assets = posts.posts.templateAssets
        let context = SiteContext(
            site: site,
            canonicalURL: site.url.appending(path: path),
            subtitle: subtitle,
            description: "Archive of all posts from \(subtitle)",
            pageType: "article",
            templateAssets: assets
        )
        return render(.monthPosts(posts), context: context)
    }

    func renderPost(_ post: Post, site: Site, path: String) throws -> String {
        let context = SiteContext(
            site: site,
            canonicalURL: site.url.appending(path: path),
            subtitle: post.title,
            description: post.excerpt,
            pageType: "article",
            templateAssets: post.templateAssets
        )
        return render(.post(post, articleClass: "container"), context: context)
    }

    func renderRecentPosts(_ posts: [Post], site: Site, path: String) throws -> String {
        let context = SiteContext(
            site: site,
            canonicalURL: site.url.appending(path: path),
            subtitle: nil,
            description: "Recent posts",
            pageType: "article",
            templateAssets: posts.templateAssets
        )
        return render(.recentPosts(posts), context: context)
    }
}
