//
//  RSSFeedPlugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-10.
//

import Foundation

final class RSSFeedPlugin: Plugin {
    let postRepo: PostRepo
    let rssFeedWriter: RSSFeedWriter

    init(
        postRepo: PostRepo = PostRepo(),
        rssFeedWriter: RSSFeedWriter = RSSFeedWriter()
    ) {
        self.postRepo = postRepo
        self.rssFeedWriter = rssFeedWriter
    }

    // MARK: - Plugin methods

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

        try rssFeedWriter.writeFeed(postRepo.postsForFeed, site: site, to: targetURL, with: templateRenderer)
    }
}
