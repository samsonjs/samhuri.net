import Foundation

public enum samhuri {}

public extension samhuri {
    struct net {
        let siteURLOverride: URL?

        public init(siteURLOverride: URL? = nil) {
            self.siteURLOverride = siteURLOverride
        }

        public func generate(sourceURL: URL, targetURL: URL) throws {
            let renderer = PageRenderer()
            let site = makeSite(renderer: renderer)
            let generator = try SiteGenerator(sourceURL: sourceURL, site: site)
            try generator.generate(targetURL: targetURL)
        }

        func makeSite(renderer: PageRenderer) -> Site {
            let projectsPlugin = ProjectsPlugin.Builder(renderer: renderer)
                .path("projects")
                .assets(TemplateAssets(scripts: [
                    "https://ajax.googleapis.com/ajax/libs/prototype/1.6.1.0/prototype.js",
                    "gitter.js",
                    "store.js",
                    "projects.js",
                ], styles: []))
                .add("samhuri.net", description: "this site")
                .add("bin", description: "my collection of scripts in ~/bin")
                .add("config", description: "important dot files (zsh, emacs, vim, screen)")
                .add("compiler", description: "a compiler targeting x86 in Ruby")
                .add("lake", description: "a simple implementation of Scheme in C")
                .add("AsyncMonitor", description: "easily monitor async sequences using Swift concurrency")
                .add("NotificationSmuggler", description: "embed strongly-typed values in notifications on Apple platforms")
                .add("strftime", description: "strftime for JavaScript")
                .add("format", description: "printf for JavaScript")
                .add("gitter", description: "a GitHub client for Node (v3 API)")
                .add("cheat.el", description: "cheat from emacs")
                .build()

            let postsPlugin = PostsPlugin.Builder(renderer: renderer)
                .path("posts")
                .jsonFeed(
                    iconPath: "images/apple-touch-icon-300.png",
                    faviconPath: "images/apple-touch-icon-80.png"
                )
                .rssFeed()
                .build()

            return Site.Builder(
                title: "samhuri.net",
                description: "Sami Samhuri's blog about programming, mainly about iOS and Ruby and Rails these days.",
                author: "Sami Samhuri",
                imagePath: "images/me.jpg",
                email: "sami@samhuri.net",
                url: siteURLOverride ?? URL(string: "https://samhuri.net")!
            )
                .styles("normalize.css", "style.css", "fontawesome.min.css", "brands.min.css", "solid.min.css")
                .renderMarkdown(pageRenderer: renderer)
                .plugin(projectsPlugin)
                .plugin(postsPlugin)
                .build()
        }
    }
}
