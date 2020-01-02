//
//  ProjectsPlugin.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

struct PartialProject {
    let title: String
    let description: String
}

final class ProjectsPlugin: Plugin {
    let fileWriter: FileWriting
    let outputPath: String
    let partialProjects: [PartialProject]
    let renderer: ProjectsRenderer
    let projectAssets: TemplateAssets

    var projects: [Project] = []
    var sourceURL: URL!

    init(
        projects: [PartialProject],
        renderer: ProjectsRenderer,
        projectAssets: TemplateAssets,
        outputPath: String? = nil,
        fileWriter: FileWriting = FileWriter()
    ) {
        self.partialProjects = projects
        self.renderer = renderer
        self.projectAssets = projectAssets
        self.outputPath = outputPath ?? "projects"
        self.fileWriter = fileWriter
    }

    // MARK: - Plugin methods

    func setUp(site: Site, sourceURL: URL) throws {
        self.sourceURL = sourceURL
        projects = partialProjects.map { partial in
            Project(
                title: partial.title,
                description: partial.description,
                url: site.url.appendingPathComponent("\(outputPath)/\(partial.title)")
            )
        }
    }

    func render(site: Site, targetURL: URL) throws {
        guard !projects.isEmpty else {
            return
        }

        let projectsDir = targetURL.appendingPathComponent(outputPath)
        let projectsURL = projectsDir.appendingPathComponent("index.html")
        let projectsHTML = try renderer.renderProjects(projects, site: site)
        try fileWriter.write(string: projectsHTML, to: projectsURL)

        for project in projects {
            let projectURL = projectsDir.appendingPathComponent("\(project.title)/index.html")
            let projectHTML = try renderer.renderProject(project, site: site, assets: projectAssets)
            try fileWriter.write(string: projectHTML, to: projectURL)
        }
    }
}
