//
//  Post.swift
//  SiteGenerator
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

    // These are computed properties but are computed eagerly because
    // Stencil is unable to use real computed properties at this time.
    let isLink: Bool
    let day: Int

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

        // Eagerly computed properties
        self.isLink = link != nil
        self.day = date.day
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
