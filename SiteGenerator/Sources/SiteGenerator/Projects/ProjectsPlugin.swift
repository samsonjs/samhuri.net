//
//  ProjectsPlugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

private struct Projects: Codable {
    let projects: [Project]

    static func decode(from url: URL) throws -> Projects {
        let json = try Data(contentsOf: url)
        let projects = try JSONDecoder().decode(Projects.self, from: json)
        return projects
    }
}

final class ProjectsPlugin: Plugin {
    let fileManager: FileManager = .default
    let outputPath: String

    var projects: [Project] = []
    var sourceURL: URL!

    init(outputPath: String? = nil) {
        self.outputPath = outputPath ?? "projects"
    }

    convenience init(options: [String: Any]) {
        if let outputPath = options["path"] as? String {
            self.init(outputPath: outputPath)
        }
        else {
            self.init()
        }
    }

    func setUp(site: Site, sourceURL: URL) throws {
        self.sourceURL = sourceURL
        let projectsURL = sourceURL.appendingPathComponent("projects.json")
        if fileManager.fileExists(atPath: projectsURL.path) {
            self.projects = try Projects.decode(from: projectsURL).projects.map { project in
                Project(title: project.title, description: project.description, path: "/\(outputPath)/\(project.title)")
            }
        }
    }

    func render(site: Site, targetURL: URL, templateRenderer: TemplateRenderer) throws {
        guard !projects.isEmpty else {
            return
        }

        let projectsDir = targetURL.appendingPathComponent(outputPath)
        try fileManager.createDirectory(at: projectsDir, withIntermediateDirectories: true, attributes: nil)
        let projectsURL = projectsDir.appendingPathComponent("index.html")
        let projectsHTML = try templateRenderer.renderTemplate(name: "projects.html", context: [
            "title": "Projects",
            "projects": projects,
        ])
        try projectsHTML.write(to: projectsURL, atomically: true, encoding: .utf8)

        for project in projects {
            let projectURL = projectsDir.appendingPathComponent("\(project.title)/index.html")
            let projectHTML = try templateRenderer.renderTemplate(name: "project.html", context: [
                "title": "\(project.title)",
                "project": project,
            ])
            try fileManager.createDirectory(at: projectURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            try projectHTML.write(to: projectURL, atomically: true, encoding: .utf8)
        }
    }
}
