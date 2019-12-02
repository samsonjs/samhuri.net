//
//  main.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

func main(sourcePath: String, targetPath: String) throws {
    let sourceURL = URL(fileURLWithPath: sourcePath)
    let targetURL = URL(fileURLWithPath: targetPath)
    let generator = try Generator(sourceURL: sourceURL)
    try generator.generate(targetURL: targetURL)
}

let sourcePath = CommandLine.arguments[1]
let targetPath = CommandLine.arguments[2]

#warning("TODO: validate args")

try! main(sourcePath: sourcePath, targetPath: targetPath)
