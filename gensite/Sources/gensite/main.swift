//
//  main.swift
//  gensite
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation
import samhuri_net

guard CommandLine.arguments.count >= 3 else {
    let name = CommandLine.arguments[0]
    FileHandle.standardError.write("Usage: \(name) <site dir> <target dir>\n".data(using: .utf8)!)
    exit(1)
}

let sourcePath = CommandLine.arguments[1]
var isDir: ObjCBool = false
let sourceExists = FileManager.default.fileExists(atPath: sourcePath, isDirectory: &isDir)
guard sourceExists, isDir.boolValue else {
    FileHandle.standardError.write("error: Site path \(sourcePath) does not exist or is not a directory\n".data(using: .utf8)!)
    exit(2)
}

let targetPath = CommandLine.arguments[2]

let siteURLOverride: URL?
if CommandLine.argc > 3, CommandLine.arguments[3].isEmpty == false {
    let urlString = CommandLine.arguments[3]
    guard let url = URL(string: urlString) else {
        FileHandle.standardError.write("error: invalid site URL \(urlString)\n".data(using: .utf8)!)
        exit(4)
    }
    siteURLOverride = url
}
else {
    siteURLOverride = nil
}

do {
    let sourceURL = URL(fileURLWithPath: sourcePath)
    let targetURL = URL(fileURLWithPath: targetPath)
    let site = samhuri.net(siteURLOverride: siteURLOverride)
    try site.generate(sourceURL: sourceURL, targetURL: targetURL)
    exit(0)
}
catch {
    FileHandle.standardError.write("error: \(error)\n".data(using: .utf8)!)
    exit(-1)
}
