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

    func construct(options: [String: Any]) -> AnyPlugin {
        switch self {
        case .posts:
            let plugin = PostsPlugin(options: options)
            return AnyPlugin(plugin)

        case .projects:
            let plugin = ProjectsPlugin(options: options)
            return AnyPlugin(plugin)
        }
    }
}
