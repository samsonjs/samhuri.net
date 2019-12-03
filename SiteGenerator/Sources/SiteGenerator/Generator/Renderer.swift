//
//  Renderer.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

public protocol RendererDelegate: AnyObject {
    func renderPage(bodyHTML: String, metadata: [String: String]) throws -> String
    func renderTemplate(name: String?, context: [String: Any]) throws -> String
}

public protocol Renderer {
    func canRenderFile(named filename: String, withExtension ext: String) -> Bool

    func render(fileURL: URL, targetDir: URL, delegate: RendererDelegate) throws
}
