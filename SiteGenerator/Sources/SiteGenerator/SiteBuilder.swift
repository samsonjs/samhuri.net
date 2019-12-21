//
//  SiteBuilder.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-15.
//

import Foundation

public final class SiteBuilder {
    private let title: String
    private let description: String?
    private let author: String
    private let email: String
    private let url: URL

    private var styles: [String] = []
    private var scripts: [String] = []

    private var plugins: [Plugin] = []
    private var renderers: [Renderer] = []

    public init(
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

    public func styles(_ styles: String...) -> SiteBuilder {
        self.styles.append(contentsOf: styles)
        return self
    }

    public func scripts(_ scripts: String...) -> SiteBuilder {
        self.scripts.append(contentsOf: scripts)
        return self
    }

    public func plugin(_ plugin: Plugin) -> SiteBuilder {
        plugins.append(plugin)
        return self
    }

    public func renderer(_ renderer: Renderer) -> SiteBuilder {
        renderers.append(renderer)
        return self
    }

    public func build() -> Site {
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

public extension SiteBuilder {
    func renderMarkdown(pageRenderer: MarkdownPageRenderer) -> SiteBuilder {
        renderer(MarkdownRenderer(pageRenderer: pageRenderer))
    }
}
