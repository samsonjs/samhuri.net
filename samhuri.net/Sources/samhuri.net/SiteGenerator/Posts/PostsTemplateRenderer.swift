//
//  PostsTemplateRenderer.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-17.
//

import Foundation

protocol PostsTemplateRenderer {
    func renderArchive(postsByYear: PostsByYear, site: Site, assets: TemplateAssets) throws -> String

    func renderYearPosts(_ yearPosts: YearPosts, site: Site, assets: TemplateAssets) throws -> String

    func renderMonthPosts(_ posts: MonthPosts, site: Site, assets: TemplateAssets) throws -> String

    func renderPost(_ post: Post, site: Site, assets: TemplateAssets) throws -> String

    func renderRecentPosts(_ posts: [Post], site: Site, assets: TemplateAssets) throws -> String

    // MARK: - Feeds

    func renderFeedPost(_ post: Post, site: Site, assets: TemplateAssets) throws -> String

    func renderRSSFeed(posts: [Post], feedURL: URL, site: Site, assets: TemplateAssets) throws -> String
}
