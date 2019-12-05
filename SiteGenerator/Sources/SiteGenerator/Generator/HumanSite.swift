//
//  HumanSite.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

/// This is used to make the JSON simpler to write with optionals.
struct HumanSite: Codable {
    let author: String
    let title: String
    let url: String
    let template: String?
    let styles: [String]?
    let scripts: [String]?
}

extension Site {
    init(humanSite: HumanSite) {
        self.author = humanSite.author
        self.title = humanSite.title
        self.url = humanSite.url
        self.template = humanSite.template ?? "page"
        self.styles = humanSite.styles ?? []
        self.scripts = humanSite.scripts ?? []
    }
}
