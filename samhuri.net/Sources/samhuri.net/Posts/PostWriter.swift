//
//  PostWriter.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-09.
//

import Foundation

final class PostWriter {
    let fileWriter: FileWriting
    let outputPath: String

    init(outputPath: String = "posts", fileWriter: FileWriting = FileWriter()) {
        self.fileWriter = fileWriter
        self.outputPath = outputPath
    }
}

// MARK: - Post pages

extension PostWriter {
    func writePosts(_ posts: [Post], for site: Site, to targetURL: URL, with renderer: PostsRendering) throws {
        for post in posts {
            let postHTML = try renderer.renderPost(post, site: site)
            let postURL = targetURL
                .appendingPathComponent(outputPath)
                .appendingPathComponent(filePath(date: post.date, slug: post.slug))
            try fileWriter.write(string: postHTML, to: postURL)
        }
    }

    private func filePath(date: Date, slug: String) -> String {
        "/\(date.year)/\(Month(date).padded)/\(slug)/index.html"
    }
}

// MARK: - Recent posts page

extension PostWriter {
    func writeRecentPosts(_ recentPosts: [Post], for site: Site, to targetURL: URL, with renderer: PostsRendering) throws {
        let recentPostsHTML = try renderer.renderRecentPosts(recentPosts, site: site)
        let fileURL = targetURL.appendingPathComponent("index.html")
        try fileWriter.write(string: recentPostsHTML, to: fileURL)
    }
}

// MARK: - Post archive page

extension PostWriter {
    func writeArchive(posts: PostsByYear, for site: Site, to targetURL: URL, with renderer: PostsRendering) throws {
        let archiveHTML = try renderer.renderArchive(postsByYear: posts, site: site)
        let archiveURL = targetURL.appendingPathComponent(outputPath).appendingPathComponent("index.html")
        try fileWriter.write(string: archiveHTML, to: archiveURL)
    }
}

// MARK: - Yearly post index pages

extension PostWriter {
    func writeYearIndexes(posts: PostsByYear, for site: Site, to targetURL: URL, with renderer: PostsRendering) throws {
        for yearPosts in posts.byYear.values {
            let yearDir = targetURL.appendingPathComponent(yearPosts.path)
            let yearHTML = try renderer.renderYearPosts(yearPosts, site: site)
            let yearURL = yearDir.appendingPathComponent("index.html")
            try fileWriter.write(string: yearHTML, to: yearURL)
        }
    }
}

// MARK: - Monthly post roll-up pages

extension PostWriter {
    func writeMonthRollups(posts: PostsByYear, for site: Site, to targetURL: URL, with renderer: PostsRendering) throws {
        for yearPosts in posts.byYear.values {
            for monthPosts in yearPosts.byMonth.values {
                let monthDir = targetURL.appendingPathComponent(monthPosts.path)
                let monthHTML = try renderer.renderMonthPosts(monthPosts, site: site)
                let monthURL = monthDir.appendingPathComponent("index.html")
                try fileWriter.write(string: monthHTML, to: monthURL)
            }
        }
    }
}
