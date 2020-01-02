//
//  ProjectsPlugin+Builder.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-19.
//

import Foundation

extension ProjectsPlugin {
    final class Builder {
        let renderer: ProjectsRenderer
        private var path: String?
        private var projects: [PartialProject] = []
        private var assets: TemplateAssets?

        init(renderer: ProjectsRenderer) {
            self.renderer = renderer
        }

        func path(_ path: String) -> Self {
            precondition(self.path == nil, "path is already defined")
            self.path = path
            return self
        }

        func assets(_ assets: TemplateAssets) -> Self {
            precondition(self.assets == nil, "assets are already defined")
            self.assets = assets
            return self
        }

        func add(_ title: String, description: String) -> Self {
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
                renderer: renderer,
                projectAssets: assets ?? .empty(),
                outputPath: path
            )
        }
    }
}
