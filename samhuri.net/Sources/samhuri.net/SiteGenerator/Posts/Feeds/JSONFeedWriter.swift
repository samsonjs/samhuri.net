//
//  JSONFeedWriter.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-10.
//

import Foundation

final class JSONFeedWriter {
    let fileWriter: FileWriting
    let jsonFeed: JSONFeed

    init(jsonFeed: JSONFeed, fileWriter: FileWriting = FileWriter()) {
        self.jsonFeed = jsonFeed
        self.fileWriter = fileWriter
    }

    func writeFeed(_ posts: [Post], for site: Site, to targetURL: URL, with templateRenderer: PostsTemplateRenderer) throws {
        let feed = Feed(
            title: site.title,
            home_page_url: site.url.absoluteString,
            feed_url: site.url.appendingPathComponent(jsonFeed.path).absoluteString,
            author: FeedAuthor(
                name: site.author,
                avatar: jsonFeed.avatarPath.map(site.url.appendingPathComponent)?.absoluteString,
                url: site.url.absoluteString
            ),
            icon: jsonFeed.iconPath.map(site.url.appendingPathComponent)?.absoluteString,
            favicon: jsonFeed.faviconPath.map(site.url.appendingPathComponent)?.absoluteString,
            items: try posts.map { post in
                let url = site.url.appendingPathComponent(post.path)
                return FeedItem(
                    title: post.isLink ? "→ \(post.title)" : post.title,
                    date_published: post.date,
                    id: url.absoluteString,
                    url: url.absoluteString,
                    external_url: post.link?.absoluteString,
                    author: FeedAuthor(name: post.author, avatar: nil, url: nil),
                    content_html: try templateRenderer.renderFeedPost(post, site: site),
                    tags: post.tags
                )
            }
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
#if os(Linux)
        encoder.outputFormatting = [.prettyPrinted]
#else
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
#endif
        let feedJSON = try encoder.encode(feed)
        let feedURL = targetURL.appendingPathComponent(jsonFeed.path)
        try fileWriter.write(data: feedJSON, to: feedURL)
    }
}

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
