# samhuri.net

Source code for [samhuri.net](https://samhuri.net), powered by a Ruby static site generator.

## Overview

This repository is now a single integrated Ruby project. The legacy Swift generators (`gensite/` and `samhuri.net/`) have been removed.

- Generator core: `lib/`
- Build tasks and utility workflows: `bake.rb`
- Tests: `spec/`
- Config: `site.toml` and `projects.toml`
- Content: `posts/` and `public/`
- Output: `www/`

## Requirements

- Ruby (see `.ruby-version`)
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

## Configuration

Site metadata and project data are configured with TOML files at the repository root:

- `site.toml`: site identity, default scripts/styles, and `projects_plugin` assets.
- `projects.toml`: project listing entries using `[[projects]]`.

`Pressa.create_site` loads both files from the provided `source_path` and still supports URL overrides for `debug`, `beta`, and `release` builds.

Other targets:

```bash
rbenv exec bundle exec bake mudge
rbenv exec bundle exec bake beta
rbenv exec bundle exec bake release
rbenv exec bundle exec bake watch target=debug
rbenv exec bundle exec bake clean
rbenv exec bundle exec bake publish_beta
rbenv exec bundle exec bake publish
```

## Draft Workflow

```bash
rbenv exec bundle exec bake new_draft "Post title"
rbenv exec bundle exec bake drafts
rbenv exec bundle exec bake publish_draft public/drafts/post-title.md
```

Published posts in `posts/YYYY/MM/*.md` require YAML front matter keys:

- `Title`
- `Author`
- `Date`
- `Timestamp`

## Tests And Lint

```bash
rbenv exec bundle exec bake test
rbenv exec bundle exec standardrb
```

Or via bake:

```bash
rbenv exec bundle exec bake test
rbenv exec bundle exec bake lint
rbenv exec bundle exec bake lint_fix
```

## Notes

- `bake watch` is Linux-only and requires `inotifywait`.
- Deployment uses `rsync` to host `mudge` (configured in `bake.rb`):
  - production: `/var/www/samhuri.net/public`
  - beta: `/var/www/beta.samhuri.net/public`
