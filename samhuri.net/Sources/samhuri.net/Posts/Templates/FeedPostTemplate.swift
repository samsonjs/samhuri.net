//
//  FeedPostTemplate.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-22.
//

import Foundation
import Plot

private extension Node where Context == HTML.BodyContext {
    static func link(_ attributes: Attribute<HTML.LinkContext>...) -> Self {
        .element(named: "link", attributes: attributes)
    }
}

extension Node where Context == HTML.BodyContext {
    static func feedPost(_ post: Post, url: URL, styles: [URL]) -> Self {
        .group([
            .group(styles.map { style in
                .link(.rel(.stylesheet), .href(style), .type("text/css"))
            }),
            .div(
                .p(.class("time"), .text(post.formattedDate)),
                .raw(post.body),
                .p(.a(.class("permalink"), .href(url), "∞"))
            ),
        ])
    }
}
