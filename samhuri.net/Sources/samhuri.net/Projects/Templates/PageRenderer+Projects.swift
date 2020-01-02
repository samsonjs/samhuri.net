//
//  PageRenderer+Projects.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-22.
//

import Foundation
import Plot

extension PageRenderer: ProjectsRenderer {
    func renderProjects(_ projects: [Project], site: Site) throws -> String {
        let context = SiteContext(site: site, subtitle: "Projects", templateAssets: .empty())
        return render(.projects(projects), context: context)
    }

    func renderProject(_ project: Project, site: Site, assets: TemplateAssets) throws -> String {
        let projectContext = ProjectContext(project: project, site: site, templateAssets: assets)
        let context = SiteContext(site: site, subtitle: project.title, templateAssets: assets)
        return render(.project(projectContext), context: context)
    }
}
