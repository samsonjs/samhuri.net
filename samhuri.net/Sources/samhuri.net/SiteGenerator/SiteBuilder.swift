//
//  SiteBuilder.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-15.
//

import Foundation

final class SiteBuilder {
    private let title: String
    private let description: String?
    private let author: String
    private let email: String
    private let url: URL

    private var styles: [String] = []
    private var scripts: [String] = []

    private var plugins: [Plugin] = []
    private var renderers: [Renderer] = []

    init(
        title: String,
        description: String? = nil,
        author: String,
        email: String,
        url: URL
    ) {
        self.title = title
        self.description = description
        self.author = author
        self.email = email
        self.url = url
    }

    func styles(_ styles: String...) -> SiteBuilder {
        self.styles.append(contentsOf: styles)
        return self
    }

    func scripts(_ scripts: String...) -> SiteBuilder {
        self.scripts.append(contentsOf: scripts)
        return self
    }

    func plugin(_ plugin: Plugin) -> SiteBuilder {
        plugins.append(plugin)
        return self
    }

    func renderer(_ renderer: Renderer) -> SiteBuilder {
        renderers.append(renderer)
        return self
    }

    func build() -> Site {
        Site(
            author: author,
            email: email,
            title: title,
            description: description,
            url: url,
            styles: styles,
            scripts: scripts,
            renderers: renderers,
            plugins: plugins
        )
    }
}

// MARK: - Markdown

extension SiteBuilder {
    func renderMarkdown(pageRenderer: MarkdownPageRenderer) -> SiteBuilder {
        renderer(MarkdownRenderer(pageRenderer: pageRenderer))
    }
}
