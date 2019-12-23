//
//  RSSFeedWriter.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-10.
//

import Foundation

final class RSSFeedWriter {
    let fileManager: FileManager
    let feed: RSSFeed

    init(fileManager: FileManager = .default, feed: RSSFeed) {
        self.fileManager = fileManager
        self.feed = feed
    }

    func writeFeed(_ posts: [Post], for site: Site, to targetURL: URL, with templateRenderer: PostsTemplateRenderer) throws {
        let feedURL = site.url.appendingPathComponent(feed.path)
        let feedXML = try templateRenderer.renderRSSFeed(posts: posts, feedURL: feedURL, site: site, assets: .none())
        let feedFileURL = targetURL.appendingPathComponent(feed.path)
        try feedXML.write(to: feedFileURL, atomically: true, encoding: .utf8)
    }
}
