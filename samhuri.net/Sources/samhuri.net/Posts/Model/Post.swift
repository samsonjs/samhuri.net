//
//  Post.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

struct Post {
    let slug: String
    let title: String
    let author: String
    let date: Date
    let formattedDate: String
    let link: URL?
    let tags: [String]
    let scripts: [Script]
    let styles: [Stylesheet]
    let body: String
    let excerpt: String
    let path: String

    var isLink: Bool {
        link != nil
    }

    var templateAssets: TemplateAssets {
        TemplateAssets(scripts: scripts, styles: styles)
    }
}

extension Post: Comparable {
    static func <(lhs: Self, rhs: Self) -> Bool {
        lhs.date < rhs.date
    }
}

extension Post: CustomDebugStringConvertible {
    var debugDescription: String {
        "<Post path=\(path) title=\"\(title)\" date=\"\(formattedDate)\" link=\(link?.absoluteString ?? "no")>"
    }
}
