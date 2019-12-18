//
//  PostsPlugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

public final class PostsPlugin: Plugin {
    let templateRenderer: PostsTemplateRenderer
    let postRepo: PostRepo
    let postWriter: PostWriter
    let jsonFeedWriter: JSONFeedWriter?
    let rssFeedWriter: RSSFeedWriter?

    init(
        templateRenderer: PostsTemplateRenderer,
        postRepo: PostRepo = PostRepo(),
        postWriter: PostWriter = PostWriter(),
        jsonFeedWriter: JSONFeedWriter?,
        rssFeedWriter: RSSFeedWriter?
    ) {
        self.templateRenderer = templateRenderer
        self.postRepo = postRepo
        self.postWriter = postWriter
        self.jsonFeedWriter = jsonFeedWriter
        self.rssFeedWriter = rssFeedWriter
    }

    // MARK: - Plugin methods

    public func setUp(site: Site, sourceURL: URL) throws {
        guard postRepo.postDataExists(at: sourceURL) else {
            return
        }

        try postRepo.readPosts(sourceURL: sourceURL)
    }

    public func render(site: Site, targetURL: URL) throws {
        guard !postRepo.isEmpty else {
            return
        }

        try postWriter.writeRecentPosts(postRepo.recentPosts, for: site, to: targetURL, with: templateRenderer)
        try postWriter.writePosts(postRepo.sortedPosts, for: site, to: targetURL, with: templateRenderer)
        try postWriter.writeArchive(posts: postRepo.posts, for: site, to: targetURL, with: templateRenderer)
        try postWriter.writeYearIndexes(posts: postRepo.posts, for: site, to: targetURL, with: templateRenderer)
        try postWriter.writeMonthRollups(posts: postRepo.posts, for: site, to: targetURL, with: templateRenderer)
        try jsonFeedWriter?.writeFeed(postRepo.postsForFeed, for: site, to: targetURL, with: templateRenderer)
        try rssFeedWriter?.writeFeed(postRepo.postsForFeed, for: site, to: targetURL, with: templateRenderer)
    }
}
