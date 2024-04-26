//
//  HTMLElements.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-18.
//

import Foundation
import Plot

extension Node where Context == HTML.HeadContext {
    static func jsonFeedLink(_ url: URLRepresentable, title: String) -> Self {
        .link(.rel(.alternate), .href(url), .type("application/json"), .attribute(named: "title", value: title))
    }
}

extension Node where Context == HTML.HeadContext {
    static func appleTouchIcon(_ url: URLRepresentable) -> Self {
        .link(.attribute(named: "rel", value: "apple-touch-icon"), .href(url))
    }

    static func safariPinnedTabIcon(_ url: URLRepresentable, color: String) -> Self {
        .link(.attribute(named: "rel", value: "mask-icon"), .attribute(named: "color", value: color), .href(url))
    }
}
