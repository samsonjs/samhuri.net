//
//  PostTemplate.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-22.
//

import Foundation
import Plot

extension Node where Context == HTML.BodyContext {
    static func post(_ post: Post) -> Self {
        .group([
            .article(
                .header(
                    .h2(postTitleLink(post)),
                    .time(.text(post.formattedDate)),
                    .a(.class("permalink"), .href(post.path), "∞")
                ),
                .raw(post.body)
            ),
            .div(.class("row clearfix"),
                .p(.class("fin"), .i(.class("fa fa-code")))
            )
        ])
    }

    static func postTitleLink(_ post: Post) -> Self {
        .if(post.isLink,
            .a(.href(post.link?.absoluteString ?? post.path), "→ \(post.title)"),
            else: .a(.href(post.path), .text(post.title))
        )
    }
}
