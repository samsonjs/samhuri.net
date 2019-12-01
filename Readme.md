# samhuri.net

The source code for [samhuri.net](https://samhuri.net).

# New version using Swift

The idea is to create a bespoke set of tools, not a general thing like Jekyll. If something can be factored out later that's a bonus, not a goal.

This is a plan for migrating from a mix of node.js (harp) and Ruby to Swift. Use Ink, John Sundell's Markdown parser, to render posts, and some other library for generating HTML. Will probably try generating HTML from code because I've never tried it and it seems fun. The pointfree.com guys have one already and Sundell is releasing one Real Soon(tm).

This version will go back to its roots and use headers at the top of markdown files. It was so much easier than indexing everything. Check out [9af9d75][] to see how nice it was back in the day. Perhaps it would even make sense to port that old version to Swift rather than working with the current version. Migrate the last few years' worth of posts over by hand since there isn't a lot there.

[9af9d75]: https://github.com/samsonjs/samhuri.net/tree/9af9d75565133104beb54f1bfdd3d4efe3e16982

Execution, trying TDD for the first time:

- [ ] Replace harp with custom Swift code

    - [ ] Write a test harness that renders a site and then checks the output with `diff -r`

    - [ ] Copy source files to their destination without transformations

    - [ ] Transform files as needed:

        - [ ] LESS -> CSS

        - [ ] ? -> HTML

            - [ ] \(decide if ? is code or templates (maybe Stencils?))

            - [ ] Port .ejs templates to the new thing

- [ ] Add a link to the code for samhuri.net somewhere ... so meta (about page?)

- [ ] Migrate posts to markdown with headers somehow

    - [ ] Decide whether to migrate from [9af9d75][] or the current harp format (probably easier to migrate the old format)

    - [ ] Migrate posts

- [ ] Generate RSS feed (ditch mustache templates)

- [ ] Generate JSON feed

- [ ] Munge HTML files to make them available without an extension (index.html hack)

- [ ] Inline CSS?

- [ ] Minify JS

- [ ] Add a server for local use and simple production setups

- [ ] Figure out an iPad workflow with minimal code. Maybe a small app with some extensions and shortcuts?
