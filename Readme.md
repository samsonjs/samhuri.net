# samhuri.net

Source code for [samhuri.net](https://samhuri.net), powered by a Ruby static site generator.

## Overview

This repository is now a single integrated Ruby project. The legacy Swift generators (`gensite/` and `samhuri.net/`) have been removed.

- Generator core: `lib/`
- Build tasks: `bake.rb`
- CLI and utilities: `bin/`
- Tests: `spec/`
- Content: `posts/` and `public/`
- Output: `www/`

## Requirements

- Ruby `3.4.1` (see `.ruby-version`)
- Bundler
- `rbenv` recommended

## Setup

```bash
bin/bootstrap
```

Or manually:

```bash
rbenv install -s "$(cat .ruby-version)"
rbenv exec bundle install
```

## Build And Serve

```bash
rbenv exec bundle exec bake debug   # build for http://localhost:8000
rbenv exec bundle exec bake serve   # serve www/ locally
```

Other targets:

```bash
rbenv exec bundle exec bake mudge
rbenv exec bundle exec bake beta
rbenv exec bundle exec bake release
rbenv exec bundle exec bake publish_beta
rbenv exec bundle exec bake publish
```

## Draft Workflow

```bash
bin/new-draft "Post title"
bin/publish-draft public/drafts/post-title.md
```

## Post Utilities

```bash
bin/convert-frontmatter posts/2025/11/some-post.md
```

## Tests And Lint

```bash
rbenv exec bundle exec rspec
rbenv exec bundle exec standardrb
```

Or via bake:

```bash
rbenv exec bundle exec bake test
rbenv exec bundle exec bake lint
```

## Site Generation CLI

```bash
bin/pressa SOURCE TARGET [URL]
# example
bin/pressa . www https://samhuri.net
```

## Notes

- `bin/watch` is Linux-only and requires `inotifywait`.
- Deployment uses `rsync` to the configured `mudge` host paths in `bake.rb` and `bin/publish`.
