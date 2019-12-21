//
//  Project.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

public struct Project {
    public let title: String
    public let description: String
    public let url: URL

    public init(title: String, description: String, url: URL) {
        self.title = title
        self.description = description
        self.url = url
    }
}
