# samhuri.net

Source code for [samhuri.net](https://samhuri.net), powered by a Ruby static site generator.

## Overview

This repository contains the Ruby static-site generator and site content for samhuri.net.

If what you want is an artisanal, hand-crafted, static site generator for your personal blog then this might be a decent starting point. If you want a static site generator for other purposes then this has the bones you need to do that too, by ripping out the bundled plugins for posts and projects and writing your own.

- Generator core: `lib/pressa/` (entrypoint: `lib/pressa.rb`)
- Build tasks and utility workflows: `bake.rb`
- Tests: `test/`
- Config: `site.toml` and `projects.toml`
- Content: `posts/` and `public/`
- Output: `www/` (HTML), `gemini/` (Gemini capsule)

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
bundle install
```

## Build And Serve

```bash
bake debug   # build for http://localhost:8000
bake serve   # serve www/ locally
```

## Configuration

Site metadata and project data are configured with TOML files at the repository root:

- `site.toml`: site identity, default scripts/styles, a `plugins` list (for example `["posts", "projects"]`), and output-specific settings under `outputs.*` (for example `outputs.html.remote_links` and `outputs.gemini.{exclude_public,recent_posts_limit,home_links}`), plus `projects_plugin` assets when that plugin is enabled.
- `projects.toml`: project listing entries using `[[projects]]`.

`Pressa.create_site` loads both files from the provided `source_path` and supports URL overrides for `debug`, `beta`, and `release` builds.

## Customizing for your site

If this workflow seems like a good fit, here is the minimum to make it your own:

- Update `site.toml` with your site identity (`author`, `email`, `title`, `description`, `url`) and any global `scripts` / `styles`.
- Set `plugins` in `site.toml` to explicitly enable features (`"posts"`, `"projects"`). Safe default if omitted is no plugins.
- Define your projects in `projects.toml` using `[[projects]]` entries with `name`, `title`, `description`, and `url`.
- Configure project-page-only assets in `site.toml` under `[projects_plugin]` (`scripts` and `styles`) when using the `"projects"` plugin.
- Configure output pipelines with `site.toml` `outputs.*` tables:
  - `[outputs.html]` supports `remote_links` (array of `{label, href, icon}`).
  - `[outputs.gemini]` supports `exclude_public`, `recent_posts_limit`, and `home_links` (array of `{label, href}`).
- Add custom plugins by implementing `Pressa::Plugin` in `lib/pressa/` and registering them in `lib/pressa/config/loader.rb`.
- Adjust rendering and layout in `lib/pressa/views/` and the static content in `public/` as needed.

Other targets:

```bash
bake mudge
bake beta
bake release
bake gemini
bake watch target=debug
bake clean
bake publish_beta
bake publish_gemini
bake publish
```

## Draft Workflow

```bash
bake new_draft "Post title"
bake drafts
bake publish_draft public/drafts/post-title.md
```

Published posts in `posts/YYYY/MM/*.md` require YAML front matter keys:

- `Title`
- `Author`
- `Date`
- `Timestamp`

## Tests And Lint

```bash
bake test
standardrb
```

Or via bake:

```bash
bake test
bake lint
bake lint_fix
```

## Notes

- `bake watch` is Linux-only and requires `inotifywait`.
- Deployment uses `rsync` to host `mudge` (configured in `bake.rb`):
  - production: `/var/www/samhuri.net/public`
  - beta: `/var/www/beta.samhuri.net/public`
  - gemini: `/var/gemini/samhuri.net`
