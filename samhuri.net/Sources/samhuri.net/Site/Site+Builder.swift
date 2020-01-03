//
//  Site+Builder.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-15.
//

import Foundation

extension Site {
    final class Builder {
        private let title: String
        private let description: String
        private let author: String
        private let email: String
        private let url: URL

        private var scripts: [Script] = []
        private var styles: [Stylesheet] = []

        private var plugins: [Plugin] = []
        private var renderers: [Renderer] = []

        init(
            title: String,
            description: String,
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

        func scripts(_ scripts: String...) -> Self {
            self.scripts.append(contentsOf: scripts.map(Script.init(ref:)))
            return self
        }

        func styles(_ styles: String...) -> Self {
            self.styles.append(contentsOf: styles.map(Stylesheet.init(ref:)))
            return self
        }

        func plugin(_ plugin: Plugin) -> Self {
            plugins.append(plugin)
            return self
        }

        func renderer(_ renderer: Renderer) -> Self {
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
                scripts: scripts,
                styles: styles,
                renderers: renderers,
                plugins: plugins
            )
        }
    }
}

// MARK: - Markdown

extension Site.Builder {
    func renderMarkdown(pageRenderer: PageRendering) -> Self {
        renderer(MarkdownRenderer(pageRenderer: pageRenderer))
    }
}
