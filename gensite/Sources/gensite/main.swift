//
//  main.swift
//  gensite
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Darwin
import Foundation
import samhuri_net

func main(sourcePath: String, targetPath: String, siteURLOverride: URL?) throws {
    let sourceURL = URL(fileURLWithPath: sourcePath)
    let targetURL = URL(fileURLWithPath: targetPath)
    let site = samhuri_net()
    try site.generate(sourceURL: sourceURL, targetURL: targetURL, siteURLOverride: siteURLOverride)
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
    exit(3)
}

let siteURLOverride: URL?
if CommandLine.argc > 3, CommandLine.arguments[3].isEmpty == false {
    let urlString = CommandLine.arguments[3]
    guard let url = URL(string: urlString) else {
        print("error: invalid site URL \(urlString)")
        exit(4)
    }
    siteURLOverride = url
}
else {
    siteURLOverride = nil
}

do {
    try main(sourcePath: sourcePath, targetPath: targetPath, siteURLOverride: siteURLOverride)
    exit(0)
}
catch {
    fputs("error: \(error)", stderr)
    exit(-1)
}
