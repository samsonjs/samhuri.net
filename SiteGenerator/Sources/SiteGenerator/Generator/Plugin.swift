//
//  Plugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

public protocol PluginDelegate: AnyObject {
    func renderPage(bodyHTML: String, metadata: [String: String]) throws -> String
    func renderTemplate(name: String?, context: [String: Any]) throws -> String
}

public protocol Plugin {
    func setUp(sourceURL: URL) throws

    func render(targetURL: URL, delegate: PluginDelegate) throws
}
