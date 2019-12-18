//
//  ProjectsTemplateRenderer.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-17.
//

import Foundation

public enum ProjectTemplate {
    case project
    case projects
}

public protocol ProjectsTemplateRenderer {
    func renderTemplate(_ template: ProjectTemplate, site: Site, context: [String: Any]) throws -> String
}
