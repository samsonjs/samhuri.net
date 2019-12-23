//
//  PostWriter.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-09.
//

import Foundation

final class PostWriter {
    let fileManager: FileManager
    let outputPath: String

    init(fileManager: FileManager = .default, outputPath: String = "posts") {
        self.fileManager = fileManager
        self.outputPath = outputPath
    }
}

// MARK: - Post pages

extension PostWriter {
    func writePosts(_ posts: [Post], for site: Site, to targetURL: URL, with templateRenderer: PostsTemplateRenderer) throws {
        for post in posts {
            let postHTML = try templateRenderer.renderPost(post, site: site, assets: .none())
            let postURL = targetURL
                .appendingPathComponent(outputPath)
                .appendingPathComponent(filePath(date: post.date, slug: post.slug))
            try fileManager.createDirectory(at: postURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            try postHTML.write(to: postURL, atomically: true, encoding: .utf8)
        }
    }

    private func filePath(date: Date, slug: String) -> String {
        "/\(date.year)/\(Month(date.month).padded)/\(slug)/index.html"
    }
}

// MARK: - Recent posts page

extension PostWriter {
    func writeRecentPosts(_ recentPosts: [Post], for site: Site, to targetURL: URL, with templateRenderer: PostsTemplateRenderer) throws {
        let recentPostsHTML = try templateRenderer.renderRecentPosts(recentPosts, site: site, assets: .none())
        let fileURL = targetURL.appendingPathComponent("index.html")
        try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try recentPostsHTML.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}

// MARK: - Post archive page

extension PostWriter {
    func writeArchive(posts: PostsByYear, for site: Site, to targetURL: URL, with templateRenderer: PostsTemplateRenderer) throws {
        let archiveHTML = try templateRenderer.renderArchive(postsByYear: posts, site: site, assets: .none())
        let archiveURL = targetURL.appendingPathComponent(outputPath).appendingPathComponent("index.html")
        try fileManager.createDirectory(at: archiveURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try archiveHTML.write(to: archiveURL, atomically: true, encoding: .utf8)
    }
}

// MARK: - Yearly post index pages

extension PostWriter {
    func writeYearIndexes(posts: PostsByYear, for site: Site, to targetURL: URL, with templateRenderer: PostsTemplateRenderer) throws {
        for yearPosts in posts.byYear.values {
            let yearDir = targetURL.appendingPathComponent(yearPosts.path)
            let yearHTML = try templateRenderer.renderYearPosts(yearPosts, site: site, assets: .none())
            let yearURL = yearDir.appendingPathComponent("index.html")
            try fileManager.createDirectory(at: yearDir, withIntermediateDirectories: true, attributes: nil)
            try yearHTML.write(to: yearURL, atomically: true, encoding: .utf8)
        }
    }
}

// MARK: - Monthly post roll-up pages

extension PostWriter {
    func writeMonthRollups(posts: PostsByYear, for site: Site, to targetURL: URL, with templateRenderer: PostsTemplateRenderer) throws {
        for yearPosts in posts.byYear.values {
            for monthPosts in yearPosts.byMonth.values {
                let monthDir = targetURL.appendingPathComponent(monthPosts.path)
                let monthHTML = try templateRenderer.renderMonthPosts(monthPosts, site: site, assets: .none())
                let monthURL = monthDir.appendingPathComponent("index.html")
                try fileManager.createDirectory(at: monthDir, withIntermediateDirectories: true, attributes: nil)
                try monthHTML.write(to: monthURL, atomically: true, encoding: .utf8)
            }
        }
    }
}
