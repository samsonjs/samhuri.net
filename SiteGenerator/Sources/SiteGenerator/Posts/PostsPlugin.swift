//
//  PostsPlugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

final class PostsPlugin: Plugin {
    let postRepo: PostRepo
    let postWriter: PostWriter
    let jsonFeedWriter: JSONFeedWriter?
    let rssFeedWriter: RSSFeedWriter?

    init(
        postRepo: PostRepo = PostRepo(),
        postWriter: PostWriter = PostWriter(),
        jsonFeedWriter: JSONFeedWriter?,
        rssFeedWriter: RSSFeedWriter?
    ) {
        self.postRepo = postRepo
        self.postWriter = postWriter
        self.jsonFeedWriter = jsonFeedWriter
        self.rssFeedWriter = rssFeedWriter
    }

    // MARK: - Plugin methods

    convenience init(options: [String: Any]) {
        let postRepo: PostRepo
        let postWriter: PostWriter
        if let outputPath = options["path"] as? String {
            postRepo = PostRepo(outputPath: outputPath)
            postWriter = PostWriter(outputPath: outputPath)
        }
        else {
            postRepo = PostRepo()
            postWriter = PostWriter()
        }

        let jsonFeedWriter: JSONFeedWriter?
        if let jsonFeedPath = options["json_feed"] as? String {
            jsonFeedWriter = JSONFeedWriter(feedPath: jsonFeedPath)
        }
        else {
            jsonFeedWriter = nil
        }

        let rssFeedWriter: RSSFeedWriter?
        if let rssFeedPath = options["rss_feed"] as? String {
            rssFeedWriter = RSSFeedWriter(feedPath: rssFeedPath)
        }
        else {
            rssFeedWriter = nil
        }

        self.init(postRepo: postRepo, postWriter: postWriter, jsonFeedWriter: jsonFeedWriter, rssFeedWriter: rssFeedWriter)
    }

    func setUp(site: Site, sourceURL: URL) throws {
        guard postRepo.postDataExists(at: sourceURL) else {
            return
        }

        try postRepo.readPosts(sourceURL: sourceURL)
    }

    func render(site: Site, targetURL: URL, templateRenderer: TemplateRenderer) throws {
        guard !postRepo.isEmpty else {
            return
        }

        try postWriter.writeRecentPosts(postRepo.recentPosts, to: targetURL, with: templateRenderer)
        try postWriter.writePosts(postRepo.sortedPosts, to: targetURL, with: templateRenderer)
        try postWriter.writeArchive(posts: postRepo.posts, to: targetURL, with: templateRenderer)
        try postWriter.writeYearIndexes(posts: postRepo.posts, to: targetURL, with: templateRenderer)
        try postWriter.writeMonthRollups(posts: postRepo.posts, to: targetURL, with: templateRenderer)
        try jsonFeedWriter?.writeFeed(postRepo.postsForFeed, site: site, to: targetURL, with: templateRenderer)
        try rssFeedWriter?.writeFeed(postRepo.postsForFeed, site: site, to: targetURL, with: templateRenderer)
    }
}
