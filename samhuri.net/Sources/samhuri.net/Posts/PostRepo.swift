//
//  PostRepo.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-09.
//

import Foundation
import Ink

struct RawPost {
    let slug: String
    let markdown: String

    private static let StripMetadataRegex = try! Regex(#"---\n.*?---\n"#).dotMatchesNewlines()

    private static let TextifyParenthesesLinksRegex = try! Regex(#"\[([\w\s.-_]*)\]\([^)]+\)"#)

    private static let TextifyBracketLinksRegex = try! Regex(#"\[([\w\s.-_]*)\]\[[^\]]+\]"#)

    private static let StripImagesRegex = try! Regex(#"!\[[\w\s.-_]*\]\([^)]+\)"#)

    private static let WhitespaceRegex = try! Regex(#"\s+"#)

    private static let StripHTMLTagsRegex = try! Regex(#"<[^>]+>"#)

    var excerpt: String {
        markdown
            .replacing(Self.StripMetadataRegex, with: "")
            .replacing(Self.StripImagesRegex, with: "") // must be before links for linked images
            .replacing(Self.TextifyParenthesesLinksRegex) { match in match.output[1].substring ?? "" }
            .replacing(Self.TextifyBracketLinksRegex) { match in match.output[1].substring ?? "" }
            .replacing(Self.StripHTMLTagsRegex, with: "")
            .replacing(Self.WhitespaceRegex, with: " ")
            .trimmingPrefix(Self.WhitespaceRegex)
            .prefix(300)
        + "..."
    }
}

final class PostRepo {
    let postsPath = "posts"
    let recentPostsCount = 10
    let feedPostsCount = 30

    let fileManager: FileManager
    let markdownParser: MarkdownParser

    private(set) var posts: PostsByYear!

    init(fileManager: FileManager = .default, markdownParser: MarkdownParser = MarkdownParser()) {
        self.fileManager = fileManager
        self.markdownParser = markdownParser
    }

    var isEmpty: Bool {
        posts == nil || posts.isEmpty
    }

    var sortedPosts: [Post] {
        posts.flattened().sorted(by: >)
    }

    var recentPosts: [Post] {
        Array(sortedPosts.prefix(recentPostsCount))
    }

    var postsForFeed: [Post] {
        Array(sortedPosts.prefix(feedPostsCount))
    }

    func postDataExists(at sourceURL: URL) -> Bool {
        let postsURL = sourceURL.appendingPathComponent(postsPath)
        return fileManager.fileExists(atPath: postsURL.path)
    }

    func readPosts(sourceURL: URL, outputPath: String) throws {
        let posts = try readRawPosts(sourceURL: sourceURL)
            .map { try makePost(from: $0, outputPath: outputPath) }
        self.posts = PostsByYear(posts: posts, path: "/\(outputPath)")
    }
}

private extension PostRepo {
    func makePost(from rawPost: RawPost, outputPath: String) throws -> Post {
        let result = markdownParser.parse(rawPost.markdown)
        let metadata = try PostMetadata(dictionary: result.metadata, slug: rawPost.slug)
        let path = pathForPost(root: outputPath, date: metadata.date, slug: rawPost.slug)
        return Post(
            slug: rawPost.slug,
            title: metadata.title,
            author: metadata.author,
            date: metadata.date,
            formattedDate: metadata.formattedDate,
            link: metadata.link,
            tags: metadata.tags,
            scripts: metadata.scripts,
            styles: metadata.styles,
            body: result.html,
            excerpt: rawPost.excerpt,
            path: path
        )
    }

    func pathForPost(root: String, date: Date, slug: String) -> String {
        // format: /{root}/{year}/{month}/{slug}
        //    e.g. /posts/2019/12/first-post
        [
            "", // leading slash
            root,
            "\(date.year)",
            Month(date).padded,
            slug,
        ].joined(separator: "/")
    }

    func readRawPosts(sourceURL: URL) throws -> [RawPost] {
        let postsURL = sourceURL.appendingPathComponent(postsPath)
        return try enumerateMarkdownFiles(directory: postsURL)
            .compactMap { url in
                do {
                    return try readRawPost(url: url)
                }
                catch {
                    print("error: Cannot read post from \(url): \(error)")
                    return nil
                }
            }
    }

    func readRawPost(url: URL) throws -> RawPost {
        let slug = url.deletingPathExtension().lastPathComponent
        let markdown = try String(contentsOf: url)
        return RawPost(slug: slug, markdown: markdown)
    }

    func enumerateMarkdownFiles(directory: URL) throws -> [URL] {
        return try fileManager.contentsOfDirectory(atPath: directory.path).flatMap { (name: String) -> [URL] in
            let url = directory.appendingPathComponent(name)
            if fileManager.directoryExists(at: url) {
                return try enumerateMarkdownFiles(directory: url)
            }
            else {
                return url.pathExtension == "md" ? [url] : []
            }
        }
    }
}
