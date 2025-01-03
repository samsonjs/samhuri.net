//
//  ProjectContext.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-19.
//

import Foundation

struct ProjectContext: TemplateContext {
    let site: Site
    let title: String
    let canonicalURL: URL
    let description: String
    let pageType = "website"
    let githubURL: URL
    let templateAssets: TemplateAssets

    init(project: Project, site: Site, templateAssets: TemplateAssets) {
        self.site = site
        self.title = project.title
        self.canonicalURL = site.url.appending(components: "projects", project.title)
        self.description = project.description
        self.githubURL = URL(string: "https://github.com/samsonjs/\(title)")!
        self.templateAssets = templateAssets
    }

    var stargazersURL: URL {
        githubURL.appendingPathComponent("stargazers")
    }

    var networkURL: URL {
        githubURL.appendingPathComponent("network/members")
    }
}
