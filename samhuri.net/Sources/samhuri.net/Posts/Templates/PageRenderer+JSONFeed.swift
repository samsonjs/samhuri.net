//
//  PageRenderer+JSONFeed.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2020-01-01.
//

import Foundation
import Plot

extension PageRenderer: JSONFeedRendering {
    func renderJSONFeedPost(_ post: Post, site: Site) throws -> String {
        let context = SiteContext(site: site, subtitle: post.title, templateAssets: post.templateAssets)
        let url = site.url.appendingPathComponent(post.path)
        // Turn relative URLs into absolute ones.
        return Node.feedPost(post, url: url, styles: context.styles)
            .render(indentedBy: .spaces(2))
            .replacingOccurrences(of: "href=\"/", with: "href=\"\(site.url)/")
            .replacingOccurrences(of: "src=\"/", with: "src=\"\(site.url)/")
    }
}
