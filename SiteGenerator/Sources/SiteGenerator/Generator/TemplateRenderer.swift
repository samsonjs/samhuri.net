//
//  templateRenderer.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

public protocol TemplateRenderer: AnyObject {
    func renderPage(bodyHTML: String, metadata: [String: String]) throws -> String
    func renderTemplate(name: String?, context: [String: Any]) throws -> String
}
