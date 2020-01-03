//
//  PostMetadata.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2020-01-01.
//

import Foundation

struct PostMetadata {
    let title: String
    let author: String
    let date: Date
    let formattedDate: String
    let link: URL?
    let tags: [String]
    let scripts: [Script]
    let styles: [Stylesheet]
}

extension PostMetadata {
    enum Error: Swift.Error {
        case deficientMetadata(slug: String, missingKeys: [String], metadata: [String: String])
        case invalidTimestamp(String)
    }

    init(dictionary: [String: String], slug: String) throws {
        let requiredKeys = ["Title", "Author", "Date", "Timestamp"]
        let missingKeys = requiredKeys.filter { dictionary[$0] == nil }
        guard missingKeys.isEmpty else {
            throw Error.deficientMetadata(slug: slug, missingKeys: missingKeys, metadata: dictionary)
        }
        guard let timestamp = dictionary["Timestamp"], let timeInterval = TimeInterval(timestamp) else {
            throw Error.invalidTimestamp(dictionary["Timestamp"]!)
        }

        self.init(
            title: dictionary["Title"]!,
            author: dictionary["Author"]!,
            date: Date(timeIntervalSince1970: timeInterval),
            formattedDate: dictionary["Date"]!,
            link: dictionary["Link"].flatMap { URL(string: $0) },
            tags: dictionary.commaSeparatedList(key: "Tags"),
            scripts: dictionary.commaSeparatedList(key: "Scripts").map(Script.init(ref:)),
            styles: dictionary.commaSeparatedList(key: "Styles").map(Stylesheet.init(ref:))
        )
    }
}
