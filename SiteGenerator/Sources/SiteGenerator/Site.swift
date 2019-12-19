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
    public let styles: [String]
    public let scripts: [String]
    public let renderers: [Renderer]
    public let plugins: [Plugin]

    public init(
        author: String,
        email: String,
        title: String,
        description: String?,
        url: URL,
        styles: [String],
        scripts: [String],
        renderers: [Renderer],
        plugins: [Plugin]
    ) {
        self.author = author
        self.email = email
        self.title = title
        self.description = description
        self.url = url
        self.styles = styles
        self.scripts = scripts
        self.renderers = renderers
        self.plugins = plugins
    }
}
