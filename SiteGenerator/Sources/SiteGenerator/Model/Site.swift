//
//  Site.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

struct Site {
    let author: String
    let title: String
    let url: String
    let template: String
    let styles: [String]
    let scripts: [String]
}

extension Site {
    static func decode(from url: URL) throws -> Site {
        let json = try Data(contentsOf: url)
        let humanSite = try JSONDecoder().decode(HumanSite.self, from: json)
        return Site(humanSite: humanSite)
    }
}
