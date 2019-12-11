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
    let email: String
    let title: String
    let description: String?
    let url: URL
    let template: String?
    let styles: [String]?
    let scripts: [String]?
}

extension Site {
    init(humanSite: HumanSite) {
        self.init(
            author: humanSite.author,
            email: humanSite.email,
            title: humanSite.title,
            description: humanSite.description,
            url: humanSite.url,
            template: humanSite.template ?? "page",
            styles: humanSite.styles ?? [],
            scripts: humanSite.scripts ?? []
        )
    }
}
