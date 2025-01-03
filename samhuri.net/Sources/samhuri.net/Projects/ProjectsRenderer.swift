//
//  ProjectsTemplateRenderer.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-17.
//

import Foundation

protocol ProjectsRenderer {
    func renderProjects(_ projects: [Project], site: Site, path: String) throws -> String

    func renderProject(_ project: Project, site: Site, path: String, assets: TemplateAssets) throws -> String
}
