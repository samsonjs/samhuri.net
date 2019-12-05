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

        - [x] Check and delete _data.json filse

    - [x] Search for other _data.json and .ejs files and eliminate any that are found

- [ ] Find a way to add the site name to HTML titles rendered by plugins

- [ ] Clean up the posts plugin

- [ ] Consider using Swift for samhuri.net as well, and then making SiteGenerator a package that it uses ... then we can use Plot or pointfree.co's swift-html

- [ ] Replace remaining Ruby with Swift

    - [ ] Generate RSS feed (ditch mustache templates)

    - [ ] Generate JSON feed

    - [ ] Munge HTML files to make them available without an extension (index.html hack, do it in the SiteGenerator)

    - [ ] Inline CSS?

    - [ ] Minify JS? Now that we're keeping node, why not ...

- [ ] Add a server for local use and simple production setups (or use a file watcher + `python -m SimpleHTTPServer`?)

- [ ] Figure out an iPad workflow with minimal code. Maybe a small app with some extensions and shortcuts?
