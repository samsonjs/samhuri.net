//
//  PostTransformer.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-09.
//

import Foundation
import Ink

final class PostTransformer {
    let markdownParser: MarkdownParser
    let outputPath: String

    init(markdownParser: MarkdownParser = MarkdownParser(), outputPath: String = "posts") {
        self.markdownParser = markdownParser
        self.outputPath = outputPath
    }

    func makePost(from rawPost: RawPost) throws -> Post {
        let result = markdownParser.parse(rawPost.markdown)
        let metadata = try parseMetadata(result.metadata)
        let path = pathForPost(date: metadata.date, slug: rawPost.slug)
        return Post(
            slug: rawPost.slug,
            title: metadata.title,
            author: metadata.author,
            date: metadata.date,
            formattedDate: metadata.formattedDate,
            link: metadata.link,
            tags: metadata.tags,
            body: result.html,
            path: path
        )
    }

    func pathForPost(date: Date, slug: String) -> String {
        // format: /posts/2019/12/first-post
        [
            "",
            outputPath,
            "\(date.year)",
            Month(date.month).padded,
            slug,
        ].joined(separator: "/")
    }
}

struct ParsedMetadata {
    let title: String
    let author: String
    let date: Date
    let formattedDate: String
    let link: URL?
    let tags: [String]
}

extension PostTransformer {
    enum Error: Swift.Error {
        case deficientMetadata(missingKeys: [String])
        case invalidTimestamp(String)
    }

    func parseMetadata(_ metadata: [String: String]) throws -> ParsedMetadata {
        let requiredKeys = ["Title", "Author", "Date", "Timestamp"]
        let missingKeys = requiredKeys.filter { metadata[$0] == nil }
        guard missingKeys.isEmpty else {
            throw Error.deficientMetadata(missingKeys: missingKeys)
        }
        guard let timeInterval = TimeInterval(metadata["Timestamp"]!) else {
            throw Error.invalidTimestamp(metadata["Timestamp"]!)
        }

        let title = metadata["Title"]!
        let author = metadata["Author"]!
        let date = Date(timeIntervalSince1970: timeInterval)
        let formattedDate = metadata["Date"]!

        let link: URL?
        if let urlString = metadata["Link"] {
            link = URL(string: urlString)!
        }
        else {
            link = nil
        }

        let tags: [String]
        if let string = metadata["Tags"] {
            tags = string.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespaces) })
        }
        else {
            tags = []
        }

        return ParsedMetadata(title: title, author: author, date: date, formattedDate: formattedDate, link: link, tags: tags)
    }
}