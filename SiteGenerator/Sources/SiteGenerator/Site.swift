//
//  Site.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

public struct Site: Codable {
    public let author: String
    public let email: String
    public let title: String
    public let url: String
}

public extension Site {
    static func decode(from url: URL) throws -> Site {
        let json = try Data(contentsOf: url)
        return try JSONDecoder().decode(Site.self, from: json)
    }
}
