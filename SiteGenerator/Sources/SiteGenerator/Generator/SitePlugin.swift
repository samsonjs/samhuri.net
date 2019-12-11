//
//  SitePlugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-10.
//

import Foundation

public enum SitePlugin: String, Codable {
    case posts
    case projects
    case jsonFeed = "json_feed"
    case rssFeed = "rss_feed"
}
