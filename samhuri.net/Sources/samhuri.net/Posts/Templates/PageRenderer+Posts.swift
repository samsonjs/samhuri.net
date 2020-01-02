//
//  PageRenderer+Posts.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-22.
//

import Foundation
import Plot

extension PageRenderer: PostsRendering {
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
}
