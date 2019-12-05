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

    var isLink: Bool {
        link != nil
    }

    var path: String {
        let dateComponents = Calendar.current.dateComponents([.year, .month], from: date)
        let year = dateComponents.year!
        let month = dateComponents.month!
        return "/" + [
            "posts",
            "\(year)",
            "\(month)",
            "\(slug)",
        ].joined(separator: "/")
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

    init(bodyMarkdown: String, metadata: [String: String]) throws {
        self.bodyMarkdown = bodyMarkdown

        let requiredKeys = ["Slug", "Title", "Author", "Date", "Timestamp", "Tags", "Path_deprecated"]
        let missingKeys = requiredKeys.filter { metadata[$0] == nil }
        guard missingKeys.isEmpty else {
            throw Error.deficientMetadata(missingKeys: missingKeys)
        }

        slug = metadata["Slug"]!
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
        tags = metadata["Tags"]!.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        let handWrittenPath = metadata["Path_deprecated"]!
        assert(path == handWrittenPath, "FUCK: Generated path (\(path)) doesn't match the hand-written one \(handWrittenPath)")
    }
}

extension Post: CustomDebugStringConvertible {
    var debugDescription: String {
        "<Post slug=\(slug) title=\"\(title)\" date=\"\(formattedDate)\" link=\(link?.absoluteString ?? "no")>"
    }
}
