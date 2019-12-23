//
//  MonthPostsTemplate.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-22.
//

import Foundation
import Plot

extension Node where Context == HTML.BodyContext {
    static func monthPosts(_ posts: MonthPosts) -> Self {
        .group([
            .div(.class("container"),
                 .h1("\(posts.month.name) \(posts.year)")
            ),
            .group(posts.posts.sorted(by: >).map { post in
                .div(.class("container"), self.post(post))
            })
        ])
    }
}
