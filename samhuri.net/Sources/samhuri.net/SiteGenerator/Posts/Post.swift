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
    let body: String
    let path: String

    init(slug: String, title: String, author: String, date: Date, formattedDate: String, link: URL?, tags: [String], body: String, path: String) {
        self.slug = slug
        self.title = title
        self.author = author
        self.date = date
        self.formattedDate = formattedDate
        self.link = link
        self.tags = tags
        self.body = body
        self.path = path
    }

    var isLink: Bool {
        link != nil
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
