//
//  Site.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

struct Site {
    let author: String
    let email: String
    let title: String
    let description: String?
    let url: URL
    let styles: [String]
    let scripts: [String]
    let renderers: [Renderer]
    let plugins: [Plugin]

    init(
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
