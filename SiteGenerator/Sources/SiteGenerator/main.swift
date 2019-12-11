//
//  main.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Darwin
import Foundation

func main(sourcePath: String, targetPath: String) throws {
    let sourceURL = URL(fileURLWithPath: sourcePath)
    let targetURL = URL(fileURLWithPath: targetPath)
    let generator = try Generator(
        sourceURL: sourceURL,
        plugins: [ProjectsPlugin(), PostsPlugin(), RSSFeedPlugin(), JSONFeedPlugin()],
        renderers: [LessRenderer(), MarkdownRenderer()]
    )
    try generator.generate(targetURL: targetURL)
}

guard CommandLine.arguments.count >= 3 else {
    let name = CommandLine.arguments[0]
    fputs("Usage: \(name) <site dir> <target dir>", stderr)
    exit(1)
}

let sourcePath = CommandLine.arguments[1]
var isDir: ObjCBool = false
let sourceExists = FileManager.default.fileExists(atPath: sourcePath, isDirectory: &isDir)
guard sourceExists, isDir.boolValue else {
    fputs("error: Site path \(sourcePath) does not exist or is not a directory", stderr)
    exit(2)
}

let targetPath = CommandLine.arguments[2]
let targetExists = FileManager.default.fileExists(atPath: targetPath)
guard !targetExists else {
    print("error: Refusing to clobber existing target \(targetPath)")
    exit(2)
}

do {
    try main(sourcePath: sourcePath, targetPath: targetPath)
    exit(0)
}
catch {
    fputs("error: \(error)", stderr)
    exit(-1)
}
