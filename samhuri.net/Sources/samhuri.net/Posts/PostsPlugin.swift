//
//  PostsPlugin.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

final class PostsPlugin: Plugin {
    typealias Renderer = PostsRendering & JSONFeedRendering & RSSFeedRendering

    let renderer: Renderer
    let postRepo: PostRepo
    let postWriter: PostWriter
    let jsonFeedWriter: JSONFeedWriter?
    let rssFeedWriter: RSSFeedWriter?

    init(
        renderer: Renderer,
        postRepo: PostRepo = PostRepo(),
        postWriter: PostWriter = PostWriter(),
        jsonFeedWriter: JSONFeedWriter?,
        rssFeedWriter: RSSFeedWriter?
    ) {
        self.renderer = renderer
        self.postRepo = postRepo
        self.postWriter = postWriter
        self.jsonFeedWriter = jsonFeedWriter
        self.rssFeedWriter = rssFeedWriter
    }

    // MARK: - Plugin methods

    func setUp(site: Site, sourceURL: URL) throws {
        guard postRepo.postDataExists(at: sourceURL) else {
            return
        }

        try postRepo.readPosts(sourceURL: sourceURL)
    }

    func render(site: Site, targetURL: URL) throws {
        guard !postRepo.isEmpty else {
            return
        }

        try postWriter.writeRecentPosts(postRepo.recentPosts, for: site, to: targetURL, with: renderer)
        try postWriter.writePosts(postRepo.sortedPosts, for: site, to: targetURL, with: renderer)
        try postWriter.writeArchive(posts: postRepo.posts, for: site, to: targetURL, with: renderer)
        try postWriter.writeYearIndexes(posts: postRepo.posts, for: site, to: targetURL, with: renderer)
        try postWriter.writeMonthRollups(posts: postRepo.posts, for: site, to: targetURL, with: renderer)
        try jsonFeedWriter?.writeFeed(site: site, posts: postRepo.postsForFeed, to: targetURL, with: renderer)
        try rssFeedWriter?.writeFeed(site: site, posts: postRepo.postsForFeed, to: targetURL, with: renderer)
    }
}
