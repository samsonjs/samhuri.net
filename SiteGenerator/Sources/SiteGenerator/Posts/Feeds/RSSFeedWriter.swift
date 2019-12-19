//
//  RSSFeedWriter.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-10.
//

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
    let feed: RSSFeed

    init(fileManager: FileManager = .default, feed: RSSFeed) {
        self.fileManager = fileManager
        self.feed = feed
    }

    func writeFeed(_ posts: [Post], for site: Site, to targetURL: URL, with templateRenderer: PostsTemplateRenderer) throws {
        let feedSite = FeedSite(
            title: site.title.escapedForXML(),
            description: site.description?.escapedForXML(),
            url: site.url.absoluteString.escapedForXML()
        )
        let renderedPosts: [FeedPost] = try posts.map { post in
            let title = post.isLink ? "→ \(post.title)" : post.title
            let author = "\(site.email) (\(post.author))"
            let url = site.url.appendingPathComponent(post.path)
            return FeedPost(
                title: title.escapedForXML(),
                date: post.date.rfc822.escapedForXML(),
                author: author.escapedForXML(),
                link: (post.link ?? url).absoluteString.escapedForXML(),
                guid: url.absoluteString.escapedForXML(),
                body: try templateRenderer.renderTemplate(.feedPost, site: site, context: [
                    "post": post,
                ]).escapedForXML()
            )
        }
        let feedXML = try templateRenderer.renderTemplate(.rssFeed, site: site, context: [
            "site": feedSite,
            "feedURL": site.url.appendingPathComponent(feed.path).absoluteString.escapedForXML(),
            "posts": renderedPosts,
        ])
        let feedURL = targetURL.appendingPathComponent(feed.path)
        try feedXML.write(to: feedURL, atomically: true, encoding: .utf8)
    }
}
