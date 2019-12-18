//
//  PostsTemplateRenderer.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-17.
//

import Foundation

public enum PostTemplate {
    case archive
    case feedPost
    case monthPosts
    case post
    case recentPosts
    case rssFeed
    case yearPosts
}

public protocol PostsTemplateRenderer {
    func renderTemplate(_ template: PostTemplate, site: Site, context: [String: Any]) throws -> String
}
