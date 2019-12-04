//
//  Renderer.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

public protocol Renderer {
    func canRenderFile(named filename: String, withExtension ext: String) -> Bool

    func render(fileURL: URL, targetDir: URL, templateRenderer: TemplateRenderer) throws
}
