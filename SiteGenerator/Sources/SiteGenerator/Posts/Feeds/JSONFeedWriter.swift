//
//  JSONFeedWriter.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-10.
//

import Foundation

private struct Feed: Codable {
    let version = "https://jsonfeed.org/version/1"
    let title: String
    let home_page_url: String
    let feed_url: String
    let author: FeedAuthor
    let icon: String?
    let favicon: String?
    let items: [FeedItem]
}

private struct FeedAuthor: Codable {
    let name: String
    let avatar: String?
    let url: String?
}

private struct FeedItem: Codable {
    let title: String
    let date_published: Date
    let id: String
    let url: String
    let external_url: String?
    let author: FeedAuthor
    let content_html: String
    let tags: [String]
}

final class JSONFeedWriter {
    let fileManager: FileManager
    let jsonFeed: JSONFeed

    init(fileManager: FileManager = .default, feed: JSONFeed) {
        self.fileManager = fileManager
        self.jsonFeed = feed
    }

    func writeFeed(_ posts: [Post], site: Site, to targetURL: URL, with templateRenderer: TemplateRenderer) throws {
        let items: [FeedItem] = try posts.map { post in
            let url = site.url.appendingPathComponent(post.path)
            return FeedItem(
                title: post.isLink ? "→ \(post.title)" : post.title,
                date_published: post.date,
                id: url.absoluteString,
                url: url.absoluteString,
                external_url: post.link?.absoluteString,
                author: FeedAuthor(name: post.author, avatar: nil, url: nil),
                content_html: try templateRenderer.renderTemplate(name: "feed-post.html", context: [
                    "post": post,
                ]),
                tags: post.tags
            )
        }
        let avatar = jsonFeed.avatarPath.map(site.url.appendingPathComponent)
        let feed: Feed = Feed(
            title: site.title,
            home_page_url: site.url.absoluteString,
            feed_url: site.url.appendingPathComponent(jsonFeed.path).absoluteString,
            author: FeedAuthor(name: site.author, avatar: avatar?.absoluteString, url: site.url.absoluteString),
            icon: jsonFeed.iconPath.map(site.url.appendingPathComponent)?.absoluteString,
            favicon: jsonFeed.faviconPath.map(site.url.appendingPathComponent)?.absoluteString,
            items: items
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        let feedJSON = try encoder.encode(feed)
        let feedURL = targetURL.appendingPathComponent(jsonFeed.path)
        try feedJSON.write(to: feedURL, options: [.atomic])
    }
}
