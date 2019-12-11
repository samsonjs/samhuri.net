//
//  JSONFeedPlugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-10.
//

import Foundation

final class JSONFeedPlugin: Plugin {
    let postRepo: PostRepo
    let jsonFeedWriter: JSONFeedWriter

    init(
        postRepo: PostRepo = PostRepo(),
        jsonFeedWriter: JSONFeedWriter = JSONFeedWriter()
    ) {
        self.postRepo = postRepo
        self.jsonFeedWriter = jsonFeedWriter
    }

    // MARK: - Plugin methods

    func setUp(site: Site, sourceURL: URL) throws {
        guard postRepo.postDataExists(at: sourceURL) else {
            return
        }

        try postRepo.readPosts(sourceURL: sourceURL, makePath: jsonFeedWriter.urlPathForPost)
    }

    func render(site: Site, targetURL: URL, templateRenderer: TemplateRenderer) throws {
        guard !postRepo.isEmpty else {
            return
        }

        try jsonFeedWriter.writeFeed(postRepo.postsForFeed, site: site, to: targetURL, with: templateRenderer)
    }
}
