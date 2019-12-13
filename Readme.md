# samhuri.net

The source code for [samhuri.net](https://samhuri.net).

# New version using Swift

The idea is to create a bespoke set of tools, not a general thing like Jekyll. If something can be factored out later that's a bonus, not a goal.

This is a plan for migrating from a mix of node.js (harp) and Ruby to Swift. Use Ink, John Sundell's Markdown parser, to render posts, and some other library for generating HTML. Will probably try generating HTML from code because I've never tried it and it seems fun. The pointfree.com guys have one already and Sundell is releasing one Real Soon(tm).

This version will go back to its roots and use headers at the top of markdown files. It was so much easier than indexing everything. Check out [the old repo][old repo] to see how nice it was back in the day. The code that renders it was separate and is available at [9af9d75][].

[old repo]: https://github.com/samsonjs/blog
[9af9d75]: https://github.com/samsonjs/samhuri.net/tree/9af9d75565133104beb54f1bfdd3d4efe3e16982

Execution, trying TDD for the first time:

- [x] Replace harp with custom Swift code

    - [x] Write a test harness that renders a site and then checks the output with `diff -r`

    - [x] Write a site generator that renders www/index.html from site.json

    - [x] Add support for site styles

    - [x] Add support for page styles

    - [x] Add support for site scripts

    - [x] Add support for page scripts

    - [x] Add support for CSS files

    - [x] Transform LESS into CSS

    - [x] Migrate static pages to the new site generator

        - [x] About

        - [x] 404 / missing (configure via .htaccess as well)

        - [x] cv

        - [x] check and delete _data.json

    - [x] Migrate projects to the new site generator

        - [x] Migrate projects page

        - [x] Migrate project page

        - [x] Check and delete _data.json

    - [x] Migrate posts to markdown with headers somehow

        - [x] Define the new format

        - [x] Decide whether to migrate from [9af9d75][] or the current harp format (probably easier to migrate the new format because posts may have been updated since then)

        - [x] Migrate posts

        - [x] Migrate year indexes

        - [x] Migrate month indexes

        - [x] Migrate index / recent posts

        - [x] Migrate archive and put it at /posts/index.html, duh!

        - [x] 301 redirect /archive to /posts, and update the header link

        - [x] Check and delete _data.json files

    - [x] Search for other _data.json and .ejs files and eliminate any that are found

- [x] Link years to year indexes in the posts archive

- [x] Fix missing days on post dates in the archive and year indexes

- [x] Find a way to add the site name to HTML titles rendered by plugins

- [x] Clean up the posts plugin

    - [x] Why don't plain data structures always work with Stencil? Maybe computed properties are a no-go but we can at least use structs instead of dictionaries for the actual rendering

    - [x] Separate I/O from transformations

    - [x] Factor the core logic out of PostsPlugin ... separate I/O from transformations? Is that an improvement or does it obscure what's happening?

    - [x] Stop validating metadata in Post, do that when rendering markdown

    - [x] Remove RenderedPost

    - [x] Move all dictionary conversions for use in template contexts to extensions

    - [x] Stop using dictionaries for template contexts, use structs w/ computed properties

- [ ] Consider using Swift for samhuri.net as well, and then making SiteGenerator a package that it uses ... then we can use Plot or pointfree.co's swift-html

- [x] Replace remaining Ruby with Swift

    - [x] Generate RSS feed (ditch mustache templates)

    - [x] Generate JSON feed

    - [x] Munge HTML files to make them available without an extension (index.html hack, do it in the SiteGenerator)

    - [x] Use perf tools on beta.samhuri.net and compare to samhuri.net to see if inlining css and minifying JS is actually worthwhile

    - [x] Inline CSS? Nope

    - [x] Minify JS? Now that we're keeping node, why not ... Nope! Ditched node too

- [ ] Munge relative URLs in the RSS and JSON feeds to be absolute instead

- [ ] Add a server for local use and simple production setups (or use a file watcher + `python -m SimpleHTTPServer`?)

- [ ] Figure out an iPad workflow with minimal code. Maybe a small app with some extensions and shortcuts?
