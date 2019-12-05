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
    let bodyMarkdown: String

    var dictionary: [String: Any] {
        var result: [String: Any] = [
            "slug": slug,
            "title": title,
            "author": author,
            "day": date.day,
            "month": date.month,
            "year": date.year,
            "formattedDate": formattedDate,
            "tags": tags
        ]
        if let link = link {
            result["isLink"] = true
            result["link"] = link
        }
        return result
    }

    func dictionary(withPath path: String) -> [String: Any] {
        var dict = dictionary
        dict["path"] = path
        return dict
    }
}

/// Posts are sorted in reverse date order.
extension Post: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        rhs.date < lhs.date
    }
}

extension Post {
    enum Error: Swift.Error {
        case deficientMetadata(missingKeys: [String])
    }

    init(slug: String, bodyMarkdown: String, metadata: [String: String]) throws {
        self.slug = slug
        self.bodyMarkdown = bodyMarkdown

        let requiredKeys = ["Title", "Author", "Date", "Timestamp"]
        let missingKeys = requiredKeys.filter { metadata[$0] == nil }
        guard missingKeys.isEmpty else {
            throw Error.deficientMetadata(missingKeys: missingKeys)
        }

        title = metadata["Title"]!
        author = metadata["Author"]!
        date = Date(timeIntervalSince1970: TimeInterval(metadata["Timestamp"]!)!)
        formattedDate = metadata["Date"]!
        if let urlString = metadata["Link"] {
            link = URL(string: urlString)!
        }
        else {
            link = nil
        }
        if let string = metadata["Tags"] {
            tags = string.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespaces) })
        }
        else {
            tags = []
        }
    }
}

extension Post: CustomDebugStringConvertible {
    var debugDescription: String {
        "<Post slug=\(slug) title=\"\(title)\" date=\"\(formattedDate)\" link=\(link?.absoluteString ?? "no")>"
    }
}
