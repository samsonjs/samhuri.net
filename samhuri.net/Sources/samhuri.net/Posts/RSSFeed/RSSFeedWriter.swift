//
//  RSSFeedWriter.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-10.
//

import Foundation

protocol RSSFeedRendering {
    func renderRSSFeed(posts: [Post], feedURL: URL, site: Site) throws -> String
}

final class RSSFeedWriter {
    let fileWriter: FileWriting
    let rssFeed: RSSFeed

    init(rssFeed: RSSFeed, fileWriter: FileWriting = FileWriter()) {
        self.rssFeed = rssFeed
        self.fileWriter = fileWriter
    }

    func writeFeed(site: Site, posts: [Post], to targetURL: URL, with renderer: RSSFeedRendering) throws {
        let feedURL = site.url.appendingPathComponent(rssFeed.path)
        let feedXML = try renderer.renderRSSFeed(posts: posts, feedURL: feedURL, site: site)
        let feedFileURL = targetURL.appendingPathComponent(rssFeed.path)
        try fileWriter.write(string: feedXML, to: feedFileURL)
    }
}
