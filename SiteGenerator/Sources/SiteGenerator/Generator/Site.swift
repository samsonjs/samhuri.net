//
//  Site.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

public struct Site {
    public let author: String
    public let email: String
    public let title: String
    public let description: String?
    public let url: URL
    public let template: String
    public let styles: [String]
    public let scripts: [String]

    // Used for JSON feed
    public let avatarPath: String?
    public let iconPath: String?
    public let faviconPath: String?
}

extension Site {
    static func decode(from url: URL) throws -> Site {
        let json = try Data(contentsOf: url)
        let humanSite = try JSONDecoder().decode(HumanSite.self, from: json)
        return Site(humanSite: humanSite)
    }
}
