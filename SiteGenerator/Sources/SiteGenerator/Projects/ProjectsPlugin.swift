//
//  ProjectsPlugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

struct PartialProject {
    let title: String
    let description: String
}

public final class ProjectsPlugin: Plugin {
    let fileManager: FileManager = .default
    let outputPath: String
    let partialProjects: [PartialProject]
    let templateRenderer: ProjectsTemplateRenderer
    let projectAssets: TemplateAssets

    var projects: [Project] = []
    var sourceURL: URL!

    init(
        projects: [PartialProject],
        templateRenderer: ProjectsTemplateRenderer,
        projectAssets: TemplateAssets,
        outputPath: String? = nil
    ) {
        self.partialProjects = projects
        self.templateRenderer = templateRenderer
        self.projectAssets = projectAssets
        self.outputPath = outputPath ?? "projects"
    }

    // MARK: - Plugin methods

    public func setUp(site: Site, sourceURL: URL) throws {
        self.sourceURL = sourceURL
        projects = partialProjects.map { partial in
            Project(
                title: partial.title,
                description: partial.description,
                url: site.url.appendingPathComponent("\(outputPath)/\(partial.title)")
            )
        }
    }

    public func render(site: Site, targetURL: URL) throws {
        guard !projects.isEmpty else {
            return
        }

        let projectsDir = targetURL.appendingPathComponent(outputPath)
        try fileManager.createDirectory(at: projectsDir, withIntermediateDirectories: true, attributes: nil)
        let projectsURL = projectsDir.appendingPathComponent("index.html")
        let projectsHTML = try templateRenderer.renderProjects(projects, site: site, assets: .none())
        try projectsHTML.write(to: projectsURL, atomically: true, encoding: .utf8)

        for project in projects {
            let projectURL = projectsDir.appendingPathComponent("\(project.title)/index.html")
            let projectHTML = try templateRenderer.renderProject(project, site: site, assets: projectAssets)
            try fileManager.createDirectory(at: projectURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            try projectHTML.write(to: projectURL, atomically: true, encoding: .utf8)
        }
    }
}
