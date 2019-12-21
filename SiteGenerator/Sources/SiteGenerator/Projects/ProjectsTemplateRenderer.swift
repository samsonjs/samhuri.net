//
//  ProjectsTemplateRenderer.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-17.
//

import Foundation

public protocol ProjectsTemplateRenderer {
    func renderProjects(_ projects: [Project], site: Site, assets: TemplateAssets) throws -> String
    func renderProject(_ project: Project, site: Site, assets: TemplateAssets) throws -> String
}
