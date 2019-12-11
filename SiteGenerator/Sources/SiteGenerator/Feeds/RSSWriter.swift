//
//  RSSWriter.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-10.
//

import HTMLEntities
import Foundation

struct FeedSite {
    let title: String
    let description: String?
    let url: String

    init(title: String, description: String?, url: URL) {
        self.title = title.htmlEscape()
        self.description = description?.htmlEscape()
        self.url = url.absoluteString.htmlEscape()
    }
}

struct FeedPost {
    let title: String
    let date: String
    let author: String
    let isLink: Bool
    let link: String
    let guid: String
    let body: String

    init(
        title: String,
        date: String,
        author: String,
        link: URL?,
        url: URL,
        body: String
    ) {
        self.title = title.htmlEscape()
        self.date = date.htmlEscape()
        self.author = author.htmlEscape()
        self.isLink = link != nil
        self.link = (link ?? url).absoluteString.htmlEscape()
        self.guid = url.absoluteString.htmlEscape()
        self.body = body.htmlEscape()
    }
}

private let rfc822Formatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "EEE, d MMM yyyy HH:mm:ss ZZZ"
    return f
}()

private extension Date {
    var rfc822: String {
        rfc822Formatter.string(from: self)
    }
}

final class RSSWriter {
    let fileManager: FileManager
    let feedPath: String
    let postsPath: String

    var baseURL: URL!

    init(fileManager: FileManager = .default, feedPath: String = "feed.xml", postsPath: String = "posts") {
        self.fileManager = fileManager
        self.feedPath = feedPath
        self.postsPath = postsPath
    }

    #warning("These urlPath methods were copied from PostsPlugin and should possibly be moved somewhere else")

    func urlPath(year: Int) -> String {
        "/\(postsPath)/\(year)"
    }

    func urlPath(year: Int, month: Month) -> String {
        urlPath(year: year).appending("/\(month.padded)")
    }

    func urlPathForPost(date: Date, slug: String) -> String {
        urlPath(year: date.year, month: Month(date.month)).appending("/\(slug)")
    }

    func writeFeed(_ posts: [Post], site: Site, to targetURL: URL, with templateRenderer: TemplateRenderer) throws {
        let renderedPosts: [FeedPost] = try posts.map { post in
            return FeedPost(
                title: post.title,
                date: post.date.rfc822,
                author: "\(site.email) (\(post.author))",
                link: post.link,
                url: site.url.appendingPathComponent(post.path),
                body: try templateRenderer.renderTemplate(name: "feed-post.html", context: [
                    "post": post,
                ])
            )
        }
        let feedXML = try templateRenderer.renderTemplate(name: "feed.xml", context: [
            "site": FeedSite(title: site.title, description: site.description, url: site.url),
            "feedURL": site.url.appendingPathComponent(feedPath).absoluteString.htmlEscape(),
            "posts": renderedPosts,
        ])
        let feedURL = targetURL.appendingPathComponent(feedPath)
        try feedXML.write(to: feedURL, atomically: true, encoding: .utf8)
    }
}
