//
//  YearPostsTemplate.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-21.
//

import Foundation
import Plot

extension Node where Context == HTML.BodyContext {
    static func yearPosts(_ posts: YearPosts) -> Self {
        .div(.class("container"),
            .h2(.class("year"),
                .a(.href(posts.path), .text(posts.title))
            ),

            .group(posts.months.sorted(by: >).map { month in
                .monthTitles(posts[month])
            })
        )
    }

    static func monthTitles(_ posts: MonthPosts) -> Self {
        .group([
            .h3(.class("month"),
                .a(.href(posts.path), "\(posts.month.name)")
            ),
            .ul(.class("archive"),
                .group(posts.posts.sorted(by: >).map { post in
                    .postItem(post, date: "\(post.date.day) \(posts.month.abbreviation)")
                })
            ),
        ])
    }
}

extension Node where Context == HTML.ListContext {
    static func postItem(_ post: Post, date: Node<HTML.BodyContext>) -> Self {
        .if(post.isLink, .li(
                .a(.href(post.link?.absoluteString ?? post.path), "→ \(post.title)"),
                .time(date),
                .a(.class("permalink"), .href(post.path), "∞")
            ),
            else: .li(
                .a(.href(post.path), .text(post.title)),
                .time(date)
            )
        )
    }
}
