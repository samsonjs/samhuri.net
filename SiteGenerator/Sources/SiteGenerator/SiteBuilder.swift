//
//  SiteBuilder.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-15.
//

import Foundation

public final class SiteBuilder {
    private let author: String
    private let title: String
    private let url: URL

    private var email: String?
    private var description: String?

    private var styles: [String] = []
    private var scripts: [String] = []

    private var plugins: [Plugin] = []
    private var renderers: [Renderer] = []

    public init(
        author: String,
        email: String? = nil,
        title: String,
        description: String? = nil,
        url: URL
    ) {
        self.author = author
        self.email = email
        self.title = title
        self.description = description
        self.url = url
    }

    public func email(_ email: String) -> SiteBuilder {
        precondition(self.email == nil, "email is already defined")
        self.email = email
        return self
    }

    public func description(_ description: String) -> SiteBuilder {
        precondition(self.description == nil, "description is already defined")
        self.description = description
        return self
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
    func renderMarkdown(defaultTemplate: String) -> SiteBuilder {
        renderer(MarkdownRenderer(defaultTemplate: defaultTemplate))
    }
}

// MARK: - Projects

public extension SiteBuilder {
    func projects(path: String? = nil) -> SiteBuilder {
        plugin(ProjectsPlugin(outputPath: path))
    }
}

// MARK: - Posts

public extension SiteBuilder {
    // anything nice we can do there?
}
