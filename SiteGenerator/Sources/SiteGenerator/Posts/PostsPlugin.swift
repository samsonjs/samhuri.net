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
    let postsPath: String
    let recentPostsPath: String

    var posts: PostsByYear!
    var sourceURL: URL!

    init(postsPath: String = "posts", recentPostsPath: String = "index.html") {
        self.postsPath = postsPath
        self.recentPostsPath = recentPostsPath
    }

    func setUp(sourceURL: URL) throws {
        self.sourceURL = sourceURL
        let postsURL = sourceURL.appendingPathComponent("posts")
        guard fileManager.fileExists(atPath: postsURL.path) else {
            return
        }

        let posts = try enumerateMarkdownFiles(directory: postsURL)
            .compactMap { (url: URL) -> Post? in
                do {
                    let markdown = try String(contentsOf: url)
                    let result = markdownParser.parse(markdown)
                    let slug = url.deletingPathExtension().lastPathComponent
                    return try Post(slug: slug, bodyMarkdown: result.html, metadata: result.metadata)
                }
                catch {
                    print("Cannot create post from markdown file \(url): \(error)")
                    return nil
                }
            }
        self.posts = PostsByYear(posts: posts)
    }

    func render(targetURL: URL, templateRenderer: TemplateRenderer) throws {
        guard posts != nil, !posts.isEmpty else {
            return
        }

        let recentPostsURL = targetURL.appendingPathComponent(recentPostsPath)
        try renderRecentPosts(targetFileURL: recentPostsURL, templateRenderer: templateRenderer)

        let postsDir = targetURL.appendingPathComponent(postsPath)
        try renderYearsAndMonths(postsDir: postsDir, templateRenderer: templateRenderer)
        try renderPostsByDate(postsDir: postsDir, templateRenderer: templateRenderer)
    }

    func renderRecentPosts(targetFileURL: URL, templateRenderer: TemplateRenderer) throws {
        print("renderRecentPosts(targetFileURL: \(targetFileURL), templateRenderer: \(templateRenderer)")
        let recentPosts = posts.flattened().prefix(10)
        let recentPostsHTML = try templateRenderer.renderTemplate(name: "recent-posts", context: ["recentPosts": recentPosts])
        try recentPostsHTML.write(to: targetFileURL, atomically: true, encoding: .utf8)
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
        let allMonths = (1 ... 12).map(Month.init(_:))
        for (year, monthPosts) in posts.byYear.sorted(by: { $1.key < $0.key }) {
            let yearDir = postsDir.appendingPathComponent("\(year)")
            var sortedPostsByMonth: [Month: [RenderedPost]] = [:]
            for month in allMonths {
                let sortedPosts = monthPosts[month].posts.sorted(by: { $1.date < $0.date })
                guard !sortedPosts.isEmpty else {
                    continue
                }

                let renderedPosts = sortedPosts.map { post -> RenderedPost in
                    let bodyHTML = markdownParser.html(from: post.bodyMarkdown)
                    return RenderedPost(post: post, body: bodyHTML)
                }
                sortedPostsByMonth[month] = renderedPosts

                let monthDir = yearDir.appendingPathComponent(month.padded)
                try fileManager.createDirectory(at: monthDir, withIntermediateDirectories: true, attributes: nil)
                #warning("FIXME: get the site name out of here somehow")
                let context: [String: Any] = [
                    "title": "samhuri.net: \(month.name) \(year)",
                    "posts": renderedPosts.map { $0.dictionary },
                ]
                let monthHTML = try templateRenderer.renderTemplate(name: "posts-month", context: context)
                let monthURL = monthDir.appendingPathComponent("index.html")
                try monthHTML.write(to: monthURL, atomically: true, encoding: .utf8)
            }

            try fileManager.createDirectory(at: yearDir, withIntermediateDirectories: true, attributes: nil)
            let months = Array(sortedPostsByMonth.keys.sorted().reversed())
            let postsByMonthForContext: [String: [[String: Any]]] = sortedPostsByMonth.reduce(into: [:]) { dict, pair in
                let (month, renderedPosts) = pair
                dict[month.padded] = renderedPosts.map { $0.dictionary }
            }
            let monthsPadded = months.map { $0.padded }
            #warning("FIXME: get the site name out of here somehow")
            let context: [String: Any] = [
                "title": "samhuri.net: \(year)",
                "path": postsPath,
                "year": year,
                "months": monthsPadded,
                "monthNames": months.reduce(into: [String: String](), { dict, month in
                    dict[month.padded] = month.name
                }),
                "monthAbbreviations": months.reduce(into: [String: String](), { dict, month in
                    dict[month.padded] = month.abbreviatedName
                }),
                "postsByMonth": postsByMonthForContext,
            ]
            let yearHTML = try templateRenderer.renderTemplate(name: "posts-year", context: context)
            let yearURL = yearDir.appendingPathComponent("index.html")
            try yearHTML.write(to: yearURL, atomically: true, encoding: .utf8)
        }
    }

    private func renderPost(_ post: Post, monthDir: URL, templateRenderer: TemplateRenderer) throws {
        print("renderPost(\(post.debugDescription), monthDir: \(monthDir), templateRenderer: \(templateRenderer)")
        try fileManager.createDirectory(at: monthDir, withIntermediateDirectories: true, attributes: nil)
        let filename = "\(post.slug).html"
        let postURL = monthDir.appendingPathComponent(filename)
        let bodyHTML = markdownParser.html(from: post.bodyMarkdown)
        let renderedPost = RenderedPost(post: post, body: bodyHTML)
        #warning("FIXME: get the site name out of here somehow")
        let postHTML = try templateRenderer.renderTemplate(name: "post", context: [
            "title": "samhuri.net: \(renderedPost.post.title)",
            "post": renderedPost.dictionary,
        ])
        try postHTML.write(to: postURL, atomically: true, encoding: .utf8)
    }

    private func enumerateMarkdownFiles(directory: URL) throws -> [URL] {
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
