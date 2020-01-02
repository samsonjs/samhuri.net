//
//  PostsPlugin+Builder.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-15.
//

import Foundation

extension PostsPlugin {
    final class Builder {
        private let renderer: Renderer
        private var path: String?
        private var jsonFeed: JSONFeed?
        private var rssFeed: RSSFeed?

        init(renderer: Renderer) {
            self.renderer = renderer
        }

        func path(_ path: String) -> Self {
            precondition(self.path == nil, "path is already defined")
            self.path = path
            return self
        }

        func jsonFeed(
            path: String? = nil,
            avatarPath: String? = nil,
            iconPath: String? = nil,
            faviconPath: String? = nil
        ) -> Self {
            precondition(jsonFeed == nil, "JSON feed is already defined")
            jsonFeed = JSONFeed(
                path: path ?? "feed.json",
                avatarPath: avatarPath,
                iconPath: iconPath,
                faviconPath: faviconPath
            )
            return self
        }

        func rssFeed(path: String? = nil) -> Self {
            precondition(rssFeed == nil, "RSS feed is already defined")
            rssFeed = RSSFeed(path: path ?? "feed.xml")
            return self
        }

        func build() -> PostsPlugin {
            let postRepo: PostRepo
            let postWriter: PostWriter
            if let outputPath = path {
                postRepo = PostRepo(outputPath: outputPath)
                postWriter = PostWriter(outputPath: outputPath)
            }
            else {
                postRepo = PostRepo()
                postWriter = PostWriter()
            }

            let jsonFeedWriter: JSONFeedWriter?
            if let jsonFeed = jsonFeed {
                jsonFeedWriter = JSONFeedWriter(jsonFeed: jsonFeed)
            }
            else {
                jsonFeedWriter = nil
            }

            let rssFeedWriter: RSSFeedWriter?
            if let rssFeed = rssFeed {
                rssFeedWriter = RSSFeedWriter(rssFeed: rssFeed)
            }
            else {
                rssFeedWriter = nil
            }

            return PostsPlugin(
                renderer: renderer,
                postRepo: postRepo,
                postWriter: postWriter,
                jsonFeedWriter: jsonFeedWriter,
                rssFeedWriter: rssFeedWriter
            )
        }
    }
}
