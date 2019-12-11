//
//  PostWriter.swift
//  SiteGenerator
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
    func writePosts(_ posts: [Post], to targetURL: URL, with templateRenderer: TemplateRenderer) throws {
        for post in posts {
            let postHTML = try templateRenderer.renderTemplate(name: "post.html", context: [
                "title": post.title,
                "post": post,
            ])
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
    func writeRecentPosts(_ recentPosts: [Post], to targetURL: URL, with templateRenderer: TemplateRenderer) throws {
        let recentPostsHTML = try templateRenderer.renderTemplate(name: "recent-posts.html", context: [
            "recentPosts": recentPosts,
        ])
        let fileURL = targetURL.appendingPathComponent("index.html")
        try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try recentPostsHTML.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}

// MARK: - Post archive page

extension PostWriter {
    func writeArchive(posts: PostsByYear, to targetURL: URL, with templateRenderer: TemplateRenderer) throws {
        let allYears = posts.byYear.keys.sorted(by: >)
        let archiveHTML = try templateRenderer.renderTemplate(name: "posts-archive.html", context: [
            "title": "Archive",
            "years": allYears.map { contextDictionaryForYearPosts(posts[$0]) },
        ])
        let archiveURL = targetURL.appendingPathComponent(outputPath).appendingPathComponent("index.html")
        try fileManager.createDirectory(at: archiveURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try archiveHTML.write(to: archiveURL, atomically: true, encoding: .utf8)
    }

    private func contextDictionaryForYearPosts(_ posts: YearPosts) -> [String: Any] {
        [
            "path": posts.path,
            "title": posts.title,
            "months": posts.months.sorted(by: >).map { month in
                contextDictionaryForMonthPosts(posts[month], year: posts.year)
            },
        ]
    }

    private func contextDictionaryForMonthPosts(_ posts: MonthPosts, year: Int) -> [String: Any] {
        [
            "path": posts.path,
            "name": posts.month.name,
            "abbreviation": posts.month.abbreviation,
            "posts": posts.posts.sorted(by: >),
        ]
    }
}

// MARK: - Yearly post index pages

extension PostWriter {
    func writeYearIndexes(posts: PostsByYear, to targetURL: URL, with templateRenderer: TemplateRenderer) throws {
        for (year, yearPosts) in posts.byYear {
            let months = yearPosts.months.sorted(by: >)
            let yearDir = targetURL.appendingPathComponent(yearPosts.path)
            let context: [String: Any] = [
                "title": yearPosts.title,
                "path": yearPosts.path,
                "year": year,
                "months": months.map { contextDictionaryForMonthPosts(posts[year][$0], year: year) },
            ]
            let yearHTML = try templateRenderer.renderTemplate(name: "posts-year.html", context: context)
            let yearURL = yearDir.appendingPathComponent("index.html")
            try fileManager.createDirectory(at: yearDir, withIntermediateDirectories: true, attributes: nil)
            try yearHTML.write(to: yearURL, atomically: true, encoding: .utf8)
        }
    }
}

// MARK: - Monthly post roll-up pages

extension PostWriter {
    func writeMonthRollups(posts: PostsByYear, to targetURL: URL, with templateRenderer: TemplateRenderer) throws {
        for (year, yearPosts) in posts.byYear {
            for month in yearPosts.months {
                let monthPosts = yearPosts[month]
                let monthDir = targetURL.appendingPathComponent(monthPosts.path)
                let monthHTML = try templateRenderer.renderTemplate(name: "posts-month.html", context: [
                    "title": "\(month.name) \(year)",
                    "posts": monthPosts.posts.sorted(by: >),
                ])
                let monthURL = monthDir.appendingPathComponent("index.html")
                try fileManager.createDirectory(at: monthDir, withIntermediateDirectories: true, attributes: nil)
                try monthHTML.write(to: monthURL, atomically: true, encoding: .utf8)
            }
        }
    }
}
