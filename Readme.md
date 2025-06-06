# samhuri.net

The source code for [samhuri.net](https://samhuri.net).

## Overview

This is a custom static site generator written in Swift and geared towards blogging, though it's built to be flexible enough to be any kind of static site. As is tradition it gets a lot more attention than my actual writing for the blog.

If what you want is an artisanal, hand-crafted, static site generator for your personal blog then this might be a decent starting point. If you want a static site generator for other purposes then this has the bones you need to do that too, by ripping out the bundled plugins for posts and projects and writing your own.

Some features:

- Plugin-based architecture, including plugins for rendering posts and projects
- Uses Markdown for posts, rendered using [Ink][] and [Plot][] by [@johnsundell][]
- Supports the notion of a link post
- Generates RSS and JSON feeds
- Runs on Linux and macOS, requires Swift 6.0+

If you don't use the posts or projects plugins then what this does at its core is transform and copy files from `public/` to `www/`, and the only transforms that it performs is Markdown to HTML. Everything else is layered on top of this foundation.

Posts are [organized by year/month directories](https://github.com/samsonjs/samhuri.net/tree/main/posts), there's [an archive page that lists all posts at /posts](https://samhuri.net/posts), plus individual pages for [each year at /posts/2011](https://samhuri.net/posts/2011) and [each month at /posts/2011/12](https://samhuri.net/posts/2011/12). You can throw [any Markdown file](https://github.com/samsonjs/samhuri.net/blob/main/public/about.md) in `public/` and it gets [rendered as HTML using your site's layout](https://samhuri.net/about).

The main project is in the [samhuri.net directory][], and there's a second project for the command line tool called [gensite][] that uses the samhuri.net package. The entry points to everything live in the Makefile and the bin/ directory so those are good starting points for exploration. This project isn't intended to be a reusable library but rather something that you can fork and make your own without doing a ton of work beyond renaming some things and plugging in your personal info.

[samhuri.net directory]: https://github.com/samsonjs/samhuri.net/tree/main/samhuri.net
[gensite]: https://github.com/samsonjs/samhuri.net/tree/main/gensite
[Ink]: https://github.com/johnsundell/ink
[Plot]: https://github.com/johnsundell/plot
[@johnsundell]: https://github.com/johnsundell

### Post format

Posts are formatted with Markdown, and require this front-matter (build will fail without these fields):

```
---
Title: What's Golden
Author: Chali 2na
Date: 5th June, 2025
Timestamp: 2025-06-05T09:41:42-07:00
Tags: Ruby, C, structs, interop
Link: https://example.net/chali-2na/whats-golden  # For link posts
---
```
## Getting started

Clone this repo and build my blog:

```bash
git clone https://github.com/samsonjs/samhuri.net.git
cd samhuri.net
make debug
```

Start a local development server:

```bash
make serve  # http://localhost:8000
make watch  # Auto-rebuild on file changes (Linux only)
```

## Workflows

Work on drafts in `public/drafts/` and publish/edit posts in `posts/YYYY/MM/`. The build process renders source files from these directories:

- posts: Markdown files organized in subdirectories by year and month that are rendered into `www/posts/YYYY/MM/`
- public: static files that are copied directly to the output directory `www/`, rendering Markdown along the way
- public/drafts: by extension this is automatically handled, nothing special for drafts they're just regular pages

```bash
bin/new-draft        # Create a new empty draft post with frontmatter
bin/new-draft hello  # You can pass in a title if you want using any number of args, quotes not needed

bin/publish-draft public/drafts/hello.md  # Publish a draft (updates date and timestamp to current time)

make debug           # Build for local development, browse at http://localhost:8000 after running make serve
make serve           # Start local server at http://localhost:8000

make beta            # Build for staging at https://beta.samhuri.net
make publish_beta    # Deploy to staging server
make release         # Build for production at https://samhuri.net
make publish         # Deploy to production server
```

## Customizing for your site

If this seems like a reasonable workflow then you could see what it takes to make it your own.

### Essential changes

0. Probably **rename everything** unless you want to impersonate me 🥸

1. **Update site configuration** in `samhuri.net/Sources/samhuri.net/samhuri.net.swift`:
   - Site title, description, author name
   - Base URL for your domain
   - RSS/JSON feed metadata

2. **Modify deployment** in `bin/publish`:
   - Update rsync destination to your server
   - Adjust staging/production URLs in Makefile

3. **Customize styling** in `public/css/style.css`

4. **Replace static assets** in `public/`:
   - Favicon, apple-touch-icon
   - About page, CV, any personal content or pages you want go in here

## How it works

There's a `Site` that contains everything needed to render the site:

```swift
struct Site {
    let author: String
    let email: String
    let title: String
    let description: String
    let imageURL: URL?
    let url: URL
    let scripts: [Script]
    let styles: [Stylesheet]
    let renderers: [Renderer]
    let plugins: [Plugin]
}
```

There are `Renderer`s that plugins use to transform files, e.g. Markdown to HTML:

```swift
protocol Renderer {
    func canRenderFile(named filename: String, withExtension ext: String?) -> Bool
    func render(site: Site, fileURL: URL, targetDir: URL) throws
}
```

And this is the `Plugin` protocol:

```swift
protocol Plugin {
    func setUp(site: Site, sourceURL: URL) throws
    func render(site: Site, targetURL: URL) throws
}
```

Your site plus its renderers and plugins defines everything that it can do.

```swift
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
                .add("bin", description: "my collection of scripts in ~/bin")
                .add("config", description: "important dot files (zsh, emacs, vim, screen)")
                .add("compiler", description: "a compiler targeting x86 in Ruby")
                .add("lake", description: "a simple implementation of Scheme in C")
                .add("strftime", description: "strftime for JavaScript")
                .add("format", description: "printf for JavaScript")
                .add("gitter", description: "a GitHub client for Node (v3 API)")
                .add("mojo.el", description: "turn emacs into a sweet mojo editor")
                .add("ThePusher", description: "Github post-receive hook router")
                .add("NorthWatcher", description: "cron for filesystem changes")
                .add("repl-edit", description: "edit Node repl commands with your text editor")
                .add("cheat.el", description: "cheat from emacs")
                .add("batteries", description: "a general purpose node library")
                .add("samhuri.net", description: "this site")
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
```

You can swap out the [posts plugin][PostsPlugin] for something that handles recipes, or photos, or documentation, or whatever. Each plugin defines how to find content files, process them, and where to put the output. So while this is currently set up as a blog generator the underlying architecture doesn't dictate that at all.

[PostsPlugin]: https://github.com/samsonjs/samhuri.net/blob/main/samhuri.net/Sources/samhuri.net/Posts/PostsPlugin.swift
[ProjectsPlugin]: https://github.com/samsonjs/samhuri.net/blob/main/samhuri.net/Sources/samhuri.net/Projects/ProjectsPlugin.swift

Here's what a plugin might look like for generating photo galleries:

```swift
final class PhotoPlugin: Plugin {
    private var galleries: [Gallery] = []

    func setUp(site: Site, sourceURL: URL) throws {
        let photosURL = sourceURL.appendingPathComponent("photos")
        let galleryDirs = try FileManager.default.contentsOfDirectory(at: photosURL, ...)

        for galleryDir in galleryDirs {
            let imageFiles = try FileManager.default.contentsOfDirectory(at: galleryDir, ...)
                .filter { $0.pathExtension.lowercased() == "jpg" }
            galleries.append(Gallery(name: galleryDir.lastPathComponent, images: imageFiles))
        }
    }

    func render(site: Site, targetURL: URL) throws {
        let galleriesURL = targetURL.appendingPathComponent("galleries")

        for gallery in galleries {
            let galleryDirectory = galleriesURL.appendingPathComponent(gallery.name)
            // Generate HTML in the targetURL directory using Ink and Plot, or whatever else you want
        }
    }
}
```

## License

Released under the terms of the [MIT license](https://sjs.mit-license.org).
