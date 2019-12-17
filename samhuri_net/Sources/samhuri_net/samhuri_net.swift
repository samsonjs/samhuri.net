import Foundation
import SiteGenerator

public struct samhuri_net {
    public init() {}

    public func generate(sourceURL: URL, targetURL: URL, siteURLOverride: URL? = nil) throws {
        let postsPlugin = PostsPluginBuilder()
            .path("posts")
            .jsonFeed(
                avatarPath: "images/me.jpg",
                iconPath: "images/apple-touch-icon-300.png",
                faviconPath: "images/apple-touch-icon-80.png"
            )
            .rssFeed()
            .build()
        let site = SiteBuilder(
            author: "Sami Samhuri",
            email: "sami@samhuri.net",
            title: "samhuri.net",
            description: "just some blog",
            url: siteURLOverride ?? URL(string: "https://samhuri.net")!
        )
            .styles("css/normalize.css", "css/style.css")
            .renderMarkdown(defaultTemplate: "page.html")
            .projects()
            .plugin(postsPlugin)
            .build()
        let generator = try SiteGenerator(sourceURL: sourceURL, site: site)
        try generator.generate(targetURL: targetURL)
    }
}
