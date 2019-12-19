import Foundation
import SiteGenerator

public enum samhuri {}

public extension samhuri {
    struct net {
        let siteURLOverride: URL?

        public init(siteURLOverride: URL? = nil) {
            self.siteURLOverride = siteURLOverride
        }

        func buildSite(renderer: PageRenderer) -> Site {
            let postsPlugin = PostsPluginBuilder(templateRenderer: renderer)
                .path("posts")
                .jsonFeed(
                    avatarPath: "images/me.jpg",
                    iconPath: "images/apple-touch-icon-300.png",
                    faviconPath: "images/apple-touch-icon-80.png"
                )
                .rssFeed()
                .build()

            return SiteBuilder(
                title: "samhuri.net",
                description: "just some blog",
                author: "Sami Samhuri",
                email: "sami@samhuri.net",
                url: siteURLOverride ?? URL(string: "https://samhuri.net")!
            )
                .styles("/css/normalize.css", "/css/style.css")
                .styles("https://netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.min.css")
                .renderMarkdown(pageRenderer: renderer)
                .projects(templateRenderer: renderer)
                .plugin(postsPlugin)
                .build()
        }

        public func generate(sourceURL: URL, targetURL: URL) throws {
            let templatesURL = sourceURL.appendingPathComponent("templates")
            let renderer = PageRenderer(templatesURL: templatesURL)
            let site = buildSite(renderer: renderer)
            let generator = try SiteGenerator(sourceURL: sourceURL, site: site)
            try generator.generate(targetURL: targetURL)
        }
    }
}
