//
//  PostRepo.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-09.
//

import Foundation

struct RawPost {
    let slug: String
    let markdown: String
}

final class PostRepo {
    let postsPath = "posts"
    let recentPostsCount = 10
    let feedPostsCount = 30

    let fileManager: FileManager
    let outputPath: String

    private(set) var posts: PostsByYear!

    init(fileManager: FileManager = .default, outputPath: String = "posts") {
        self.fileManager = fileManager
        self.outputPath = outputPath
    }

    var isEmpty: Bool {
        posts == nil || posts.isEmpty
    }

    var sortedPosts: [Post] {
        posts?.flattened().sorted(by: >) ?? []
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

    func readPosts(sourceURL: URL) throws {
        let postTransformer = PostTransformer(outputPath: outputPath)
        let posts = try readRawPosts(sourceURL: sourceURL)
            .map(postTransformer.makePost)
        self.posts = PostsByYear(posts: posts, path: "/\(outputPath)")
    }

    private func readRawPosts(sourceURL: URL) throws -> [RawPost] {
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

    private func readRawPost(url: URL) throws -> RawPost {
        let slug = url.deletingPathExtension().lastPathComponent
        let markdown = try String(contentsOf: url)
        return RawPost(slug: slug, markdown: markdown)
    }

    private func enumerateMarkdownFiles(directory: URL) throws -> [URL] {
        return try fileManager.contentsOfDirectory(atPath: directory.path).flatMap { (filename: String) -> [URL] in
            let fileURL = directory.appendingPathComponent(filename)
            var isDir: ObjCBool = false
            fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDir)
            if isDir.boolValue {
                return try enumerateMarkdownFiles(directory: fileURL)
            }
            else {
                return fileURL.pathExtension == "md" ? [fileURL] : []
            }
        }
    }
}