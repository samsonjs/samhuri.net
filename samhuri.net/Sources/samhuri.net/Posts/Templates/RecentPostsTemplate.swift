//
//  RecentPostsTemplate.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-22.
//

import Foundation
import Plot

extension Node where Context == HTML.BodyContext {
    static func recentPosts(_ posts: [Post]) -> Self {
        .div(.class("container"),
             .group(posts.map { self.post($0) })
        )
    }
}
