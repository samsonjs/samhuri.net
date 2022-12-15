# samhuri.net

The source code for [samhuri.net](https://samhuri.net).

## Overview

This is a custom static site generator written in Swift and geared towards blogging. As is tradition it gets a lot more attention than my actual blog.

Some features:

- Uses Markdown for posts, rendered using [Ink][] and [Plot][] by [@johnsundell][]
- Supports the notion of a link post
- Generates RSS and JSON feeds
- Generates an archive page that lists all posts
- Generates listings for each year and month as well
- Runs on Linux and macOS

The main project is in the [samhuri.net directory][], and there's a second project for the command line tool called [gensite][] that uses the samhuri.net package to render source files from the following directories:

- drafts: flat directory of Markdown files that are rendered into `www/drafts/`
- posts: Markdown files organized in subdirectories by year and month that are rendered into `www/posts/YYYY/MM/`
- public: static files that are copied directly to the output directory `www/`

The entry points to everything live in the Makefile and the bin/ directory so those are good starting points for exploration. I may or may not document anything else about this project as it's not really intended to be a reusable library. However you should be able to fork it and make it your own without doing a ton of work as I tried not to hardcode my personal info.

If what you want is an artisinal, hand-crafted, static site generator for your personal blog then this might be a decent starting point.

[samhuri.net directory]: https://github.com/samsonjs/samhuri.net/tree/main/samhuri.net
[gensite]: https://github.com/samsonjs/samhuri.net/tree/main/gensite
[Ink]: https://github.com/johnsundell/ink
[Plot]: https://github.com/johnsundell/plot
[@johnsundell]: https://github.com/johnsundell

## License

Released under the terms of the [MIT license](https://sjs.mit-license.org).
