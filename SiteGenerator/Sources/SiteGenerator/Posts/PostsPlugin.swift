//
//  PostsPlugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation
import Ink

final class PostsPlugin: Plugin {
    let fileManager: FileManager = .default
    let markdownParser = MarkdownParser()
    let path: String

    var posts: PostsByYear!
    var sourceURL: URL!

    init(path: String = "posts") {
        self.path = path
    }

    func setUp(sourceURL: URL) throws {
        self.sourceURL = sourceURL
        let postsURL = sourceURL.appendingPathComponent("posts")
        guard fileManager.fileExists(atPath: postsURL.path) else {
            return
        }

        let posts = try enumerateMarkdownFiles(directory: postsURL)
            .compactMap { (url: URL) -> Post? in
                guard let result = (try? String(contentsOf: url)).map(markdownParser.parse) else {
                    return nil
                }
                do {
                    return try Post(bodyMarkdown: "(TEST)", metadata: result.metadata)
                }
                catch {
                    print("Cannot create post from markdown file \(url): \(error)")
                    return nil
                }
            }
        print("posts: \(posts)")
        self.posts = PostsByYear(posts: posts)
    }

    func render(targetURL: URL, templateRenderer: TemplateRenderer) throws {
        guard posts != nil, !posts.isEmpty else {
            return
        }

        let postsDir = targetURL.appendingPathComponent(path)
        try renderRecentPosts(postsDir: postsDir, templateRenderer: templateRenderer)
        try renderYearsAndMonths(postsDir: postsDir, templateRenderer: templateRenderer)
        try renderPostsByDate(postsDir: postsDir, templateRenderer: templateRenderer)
    }

    func renderRecentPosts(postsDir: URL, templateRenderer: TemplateRenderer) throws {
        print("renderRecentPosts(postsDir: \(postsDir), templateRenderer: \(templateRenderer)")
        let recentPosts = posts.flattened().prefix(10)
        try fileManager.createDirectory(at: postsDir, withIntermediateDirectories: true, attributes: nil)
        let recentPostsURL = postsDir.appendingPathComponent("index.html")
        let recentPostsHTML = try templateRenderer.renderTemplate(name: "recent-posts", context: ["recentPosts": recentPosts])
        try recentPostsHTML.write(to: recentPostsURL, atomically: true, encoding: .utf8)
    }

    func renderPostsByDate(postsDir: URL, templateRenderer: TemplateRenderer) throws {
        print("renderPostsByDate(postsDir: \(postsDir), templateRenderer: \(templateRenderer)")
        for post in posts.flattened() {
            let monthDir = postsDir
                .appendingPathComponent(String(format: "%02d", post.date.year))
                .appendingPathComponent(String(format: "%02d", post.date.month))
            try renderPost(post, monthDir: monthDir, templateRenderer: templateRenderer)
        }
    }

    func renderYearsAndMonths(postsDir: URL, templateRenderer: TemplateRenderer) throws {
        print("renderYearsAndMonths(postsDir: \(postsDir), templateRenderer: \(templateRenderer)")
        let allMonths = (1 ... 12).reversed().map(Month.init)
        for (year, monthPosts) in posts.byYear.sorted(by: { $1.key < $0.key }) {
            let yearDir = postsDir.appendingPathComponent("\(year)")
            var sortedPostsByMonth: [Int: [RenderedPost]] = [:]
            for month in allMonths {
                let sortedPosts = monthPosts[month.number].posts.sorted(by: { $1.date < $0.date })
                guard !sortedPosts.isEmpty else {
                    continue
                }

                let renderedPosts = sortedPosts.map { post -> RenderedPost in
                    let bodyHTML = markdownParser.html(from: post.bodyMarkdown)
                    return RenderedPost(post: post, body: bodyHTML)
                }
                sortedPostsByMonth[month.number] = renderedPosts

                let monthDir = yearDir.appendingPathComponent(month.padded)
                try fileManager.createDirectory(at: monthDir, withIntermediateDirectories: true, attributes: nil)
                let context: [String: Any] = ["path": path, "month": month, "posts": renderedPosts]
                let monthHTML = try templateRenderer.renderTemplate(name: "posts-month", context: context)
                let monthURL = monthDir.appendingPathComponent("index.html")
                try monthHTML.write(to: monthURL, atomically: true, encoding: .utf8)
            }

            try fileManager.createDirectory(at: yearDir, withIntermediateDirectories: true, attributes: nil)
            let context: [String: Any] = [
                "path": path,
                "year": year,
                "months": sortedPostsByMonth.keys.sorted().reversed().map(Month.init),
                "postsByMonth": sortedPostsByMonth,
            ]
            let yearHTML = try templateRenderer.renderTemplate(name: "posts-year", context: context)
            let yearURL = yearDir.appendingPathComponent("index.html")
            try yearHTML.write(to: yearURL, atomically: true, encoding: .utf8)
        }
    }

    private func renderPost(_ post: Post, monthDir: URL, templateRenderer: TemplateRenderer) throws {
        print("renderPost(\(post), monthDir: \(monthDir), templateRenderer: \(templateRenderer)")
        try fileManager.createDirectory(at: monthDir, withIntermediateDirectories: true, attributes: nil)
        let filename = "\(post.slug).html"
        let postURL = monthDir.appendingPathComponent(filename)
        let templateName = self.templateName(for: post)
        let bodyHTML = markdownParser.html(from: post.bodyMarkdown)
        let renderedPost = RenderedPost(post: post, body: bodyHTML)
        let postHTML = try templateRenderer.renderTemplate(name: templateName, context: ["post": renderedPost])
        try postHTML.write(to: postURL, atomically: true, encoding: .utf8)
    }

    private func templateName(for post: Post) -> String {
        post.isLink ? "post-link" : "post-text"
    }

    private func enumerateMarkdownFiles(directory: URL) throws -> [URL] {
        print("enumerateMarkdownFiles(directory: \(directory))")
        return try fileManager.contentsOfDirectory(atPath: directory.path).flatMap { (filename: String) -> [URL] in
            let fileURL = directory.appendingPathComponent(filename)
            var isDir: ObjCBool = false
            fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDir)
            if isDir.boolValue {
                return try enumerateMarkdownFiles(directory: fileURL)
            }
            else {
                return fileURL.pathExtension == "md" ? [fileURL] : []
            }
        }
    }
}
