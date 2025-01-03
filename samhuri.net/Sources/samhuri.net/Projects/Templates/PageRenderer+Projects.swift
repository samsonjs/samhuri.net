//
//  PageRenderer+Projects.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-22.
//

import Foundation
import Plot

extension PageRenderer: ProjectsRenderer {
    func renderProjects(_ projects: [Project], site: Site, path: String) throws -> String {
        let context = SiteContext(
            site: site,
            canonicalURL: site.url.appending(path: path),
            subtitle: "Projects",
            templateAssets: .empty()
        )
        return render(.projects(projects), context: context)
    }

    func renderProject(_ project: Project, site: Site, path: String, assets: TemplateAssets) throws -> String {
        let projectContext = ProjectContext(project: project, site: site, templateAssets: assets)
        let context = SiteContext(
            site: site,
            canonicalURL: site.url.appending(path: path),
            subtitle: project.title,
            description: project.description,
            templateAssets: assets
        )
        return render(.project(projectContext), context: context)
    }
}
