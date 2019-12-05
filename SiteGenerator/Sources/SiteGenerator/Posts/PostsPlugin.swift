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

        let postsDir = targetURL.appendingPathComponent(postsPath)
        try renderPostsByDate(postsDir: postsDir, templateRenderer: templateRenderer)
        try renderYears(postsDir: postsDir, templateRenderer: templateRenderer)
        try renderMonths(postsDir: postsDir, templateRenderer: templateRenderer)
        try renderArchive(postsDir: postsDir, templateRenderer: templateRenderer)
        try renderRecentPosts(targetURL: targetURL, templateRenderer: templateRenderer)
    }

    func renderPostsByDate(postsDir: URL, templateRenderer: TemplateRenderer) throws {
        print("renderPostsByDate(postsDir: \(postsDir), templateRenderer: \(templateRenderer)")
        for post in posts.flattened() {
            let monthDir = postsDir
                .appendingPathComponent("\(post.date.year)")
                .appendingPathComponent(Month(post.date.month).padded)
            try renderPost(post, monthDir: monthDir, templateRenderer: templateRenderer)
        }
    }

    func renderRecentPosts(targetURL: URL, templateRenderer: TemplateRenderer) throws {
        print("renderRecentPosts(targetURL: \(targetURL), templateRenderer: \(templateRenderer)")
        let recentPosts = posts.flattened().prefix(10)
        let renderedRecentPosts: [[String: Any]] = recentPosts.map { post in
            let html = markdownParser.html(from: post.bodyMarkdown)
            let path = self.path(for: post)
            return RenderedPost(path: path, post: post, body: html).dictionary
        }
        let recentPostsHTML = try templateRenderer.renderTemplate(name: "recent-posts", context: [
            "recentPosts": renderedRecentPosts,
        ])
        let fileURL = targetURL.appendingPathComponent(recentPostsPath)
        try recentPostsHTML.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    func renderArchive(postsDir: URL, templateRenderer: TemplateRenderer) throws {
        print("renderArchive(postsDir: \(postsDir), templateRenderer: \(templateRenderer)")
        let allYears = posts.byYear.keys.sorted(by: >)
        let allMonths = (1 ... 12).map(Month.init(_:))
        let yearsWithPostsByMonthForContext: [[String: Any]] = allYears.map { year in
            [
                "path": self.path(year: year),
                "title": "\(year)",
                "months": posts[year].byMonth.keys.sorted(by: >).map { (month: Month) -> [String: Any] in
                    let sortedPosts = posts[year][month].posts.sorted(by: { $0.date > $1.date })
                    return [
                        "path": self.path(year: year, month: month),
                        "title": month.padded,
                        "posts": sortedPosts.map { $0.dictionary(withPath: self.path(for: $0)) },
                    ]
                },
            ]
        }
        let context: [String: Any] = [
            "title": "Archive",
            "years": yearsWithPostsByMonthForContext,
            "monthNames": allMonths.reduce(into: [String: String](), { dict, month in
                dict[month.padded] = month.name
            }),
            "monthAbbreviations": allMonths.reduce(into: [String: String](), { dict, month in
                dict[month.padded] = month.abbreviatedName
            }),
        ]
        let archiveHTML = try templateRenderer.renderTemplate(name: "posts-archive", context: context)
        let archiveURL = postsDir.appendingPathComponent("index.html")
        try archiveHTML.write(to: archiveURL, atomically: true, encoding: .utf8)
    }

    func renderYears(postsDir: URL, templateRenderer: TemplateRenderer) throws {
        print("renderYears(postsDir: \(postsDir), templateRenderer: \(templateRenderer)")
        let allMonths = (1 ... 12).map(Month.init(_:))
        for (year, monthPosts) in posts.byYear.sorted(by: { $1.key < $0.key }) {
            let yearDir = postsDir.appendingPathComponent("\(year)")
            var sortedPostsByMonth: [Month: [Post]] = [:]
            for month in allMonths {
                let sortedPosts = monthPosts[month].posts.sorted(by: { $1.date < $0.date })
                if !sortedPosts.isEmpty {
                    sortedPostsByMonth[month] = sortedPosts
                }
            }

            try fileManager.createDirectory(at: yearDir, withIntermediateDirectories: true, attributes: nil)
            let months = Array(sortedPostsByMonth.keys.sorted().reversed())
            let postsByMonthForContext: [String: [[String: Any]]] = sortedPostsByMonth.reduce(into: [:]) { dict, pair in
                let (month, posts) = pair
                dict[month.padded] = posts.map { $0.dictionary(withPath: self.path(for: $0)) }
            }
            let context: [String: Any] = [
                "title": "\(year)",
                "path": postsPath,
                "year": year,
                "months": months.map { $0.padded },
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

    func renderMonths(postsDir: URL, templateRenderer: TemplateRenderer) throws {
        print("renderMonths(postsDir: \(postsDir), templateRenderer: \(templateRenderer)")
        let allMonths = (1 ... 12).map(Month.init(_:))
        for (year, monthPosts) in posts.byYear.sorted(by: { $1.key < $0.key }) {
            let yearDir = postsDir.appendingPathComponent("\(year)")
            for month in allMonths {
                let sortedPosts = monthPosts[month].posts.sorted(by: { $1.date < $0.date })
                guard !sortedPosts.isEmpty else {
                    continue
                }

                let renderedPosts = sortedPosts.map { post -> RenderedPost in
                    let path = self.path(for: post)
                    let bodyHTML = markdownParser.html(from: post.bodyMarkdown)
                    return RenderedPost(path: path, post: post, body: bodyHTML)
                }
                let monthDir = yearDir.appendingPathComponent(month.padded)
                try fileManager.createDirectory(at: monthDir, withIntermediateDirectories: true, attributes: nil)
                let context: [String: Any] = [
                    "title": "\(month.name) \(year)",
                    "posts": renderedPosts.map { $0.dictionary },
                ]
                let monthHTML = try templateRenderer.renderTemplate(name: "posts-month", context: context)
                let monthURL = monthDir.appendingPathComponent("index.html")
                try monthHTML.write(to: monthURL, atomically: true, encoding: .utf8)
            }
        }
    }

    private func renderPost(_ post: Post, monthDir: URL, templateRenderer: TemplateRenderer) throws {
        print("renderPost(\(post.debugDescription), monthDir: \(monthDir), templateRenderer: \(templateRenderer)")
        try fileManager.createDirectory(at: monthDir, withIntermediateDirectories: true, attributes: nil)
        let filename = "\(post.slug).html"
        let path = self.path(for: post)
        let postURL = monthDir.appendingPathComponent(filename)
        let bodyHTML = markdownParser.html(from: post.bodyMarkdown)
        let renderedPost = RenderedPost(path: path, post: post, body: bodyHTML)
        let postHTML = try templateRenderer.renderTemplate(name: "post", context: [
            "title": "\(renderedPost.post.title)",
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

    private func path(for post: Post) -> String {
        path(year: post.date.year, month: Month(post.date.month), filename: "\(post.slug).html")
    }

    private func path(year: Int) -> String {
        "/\(postsPath)/\(year)"
    }

    private func path(year: Int, month: Month) -> String {
        path(year: year).appending("/\(month.padded)")
    }

    private func path(year: Int, month: Month, filename: String) -> String {
        path(year: year, month: month).appending("/\(filename)")
    }
}
