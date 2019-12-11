//
//  RSSFeedPlugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-10.
//

import Foundation

final class RSSFeedPlugin: Plugin {
    let postRepo: PostRepo
    let rssWriter: RSSWriter

    init(
        postRepo: PostRepo = PostRepo(),
        rssWriter: RSSWriter = RSSWriter()
    ) {
        self.postRepo = postRepo
        self.rssWriter = rssWriter
    }

    // MARK: - Plugin methods

    func setUp(site: Site, sourceURL: URL) throws {
        guard postRepo.postDataExists(at: sourceURL) else {
            return
        }

        try postRepo.readPosts(sourceURL: sourceURL, makePath: rssWriter.urlPathForPost)
    }

    func render(site: Site, targetURL: URL, templateRenderer: TemplateRenderer) throws {
        guard !postRepo.isEmpty else {
            return
        }

        try rssWriter.writeFeed(postRepo.postsForFeed, site: site, to: targetURL, with: templateRenderer)
    }
}
