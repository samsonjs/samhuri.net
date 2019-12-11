//
//  RSSFeedWriter.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-10.
//

import HTMLEntities
import Foundation

private struct FeedSite {
    let title: String
    let description: String?
    let url: String
}

private struct FeedPost {
    let title: String
    let date: String
    let author: String
    let link: String
    let guid: String
    let body: String
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

final class RSSFeedWriter {
    let fileManager: FileManager
    let feedPath: String

    init(fileManager: FileManager = .default, feedPath: String = "feed.xml") {
        self.fileManager = fileManager
        self.feedPath = feedPath
    }

    func writeFeed(_ posts: [Post], site: Site, to targetURL: URL, with templateRenderer: TemplateRenderer) throws {
        let feedSite = FeedSite(
            title: site.title.htmlEscape(useNamedReferences: true),
            description: site.description?.htmlEscape(useNamedReferences: true),
            url: site.url.absoluteString.htmlEscape(useNamedReferences: true)
        )
        let renderedPosts: [FeedPost] = try posts.map { post in
            let title = post.isLink ? "→ \(post.title)" : post.title
            let author: String = {
                if let email = site.email {
                    return "\(email) (\(post.author))"
                }
                else {
                    return post.author
                }
            }()
            let url = site.url.appendingPathComponent(post.path)
            return FeedPost(
                title: title.htmlEscape(useNamedReferences: true),
                date: post.date.rfc822.htmlEscape(useNamedReferences: true),
                author: author.htmlEscape(useNamedReferences: true),
                link: (post.link ?? url).absoluteString.htmlEscape(useNamedReferences: true),
                guid: url.absoluteString.htmlEscape(useNamedReferences: true),
                body: try templateRenderer.renderTemplate(name: "feed-post.html", context: [
                    "post": post,
                ]).htmlEscape(useNamedReferences: true)
            )
        }
        let feedXML = try templateRenderer.renderTemplate(name: "feed.xml", context: [
            "site": feedSite,
            "feedURL": site.url.appendingPathComponent(feedPath).absoluteString.htmlEscape(useNamedReferences: true),
            "posts": renderedPosts,
        ])
        let feedURL = targetURL.appendingPathComponent(feedPath)
        try feedXML.write(to: feedURL, atomically: true, encoding: .utf8)
    }
}
