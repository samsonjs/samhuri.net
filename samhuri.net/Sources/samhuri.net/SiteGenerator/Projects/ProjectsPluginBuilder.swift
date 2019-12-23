//
//  ProjectsPluginBuilder.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-19.
//

import Foundation

final class ProjectsPluginBuilder {
    let templateRenderer: ProjectsTemplateRenderer
    private var path: String?
    private var projects: [PartialProject] = []
    private var projectAssets: TemplateAssets?

    init(templateRenderer: ProjectsTemplateRenderer) {
        self.templateRenderer = templateRenderer
    }

    func path(_ path: String) -> ProjectsPluginBuilder {
        precondition(self.path == nil, "path is already defined")
        self.path = path
        return self
    }

    func projectAssets(_ projectAssets: TemplateAssets) -> ProjectsPluginBuilder {
        precondition(self.projectAssets == nil, "projectAssets are already defined")
        self.projectAssets = projectAssets
        return self
    }

    func add(_ title: String, description: String) -> ProjectsPluginBuilder {
        let project = PartialProject(title: title, description: description)
        projects.append(project)
        return self
    }

    func build() -> ProjectsPlugin {
        if projects.isEmpty {
            print("WARNING: No projects have been added")
        }
        return ProjectsPlugin(
            projects: projects,
            templateRenderer: templateRenderer,
            projectAssets: projectAssets ?? .none(),
            outputPath: path
        )
    }
}
