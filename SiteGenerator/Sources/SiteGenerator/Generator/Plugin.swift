//
//  Plugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

public protocol Plugin {
    func setUp(sourceURL: URL) throws

    func render(targetURL: URL, templateRenderer: TemplateRenderer) throws
}
