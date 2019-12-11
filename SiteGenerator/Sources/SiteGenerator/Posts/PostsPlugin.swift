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

    init(
        postRepo: PostRepo = PostRepo(),
        postWriter: PostWriter = PostWriter()
    ) {
        self.postRepo = postRepo
        self.postWriter = postWriter
    }

    // MARK: - Plugin methods

    convenience init(options: [String: Any]) {
        if let outputPath = options["path"] as? String {
            self.init(postWriter: PostWriter(outputPath: outputPath))
        }
        else {
            self.init()
        }
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
    }
}
