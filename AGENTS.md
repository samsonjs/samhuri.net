# Repository Guidelines

## Project Structure & Module Organization
This repository is a Ruby static-site generator (Pressa) that outputs both HTML and Gemini formats.

- Generator code: `lib/pressa/` (entrypoint: `lib/pressa.rb`)
- Build/deploy/draft tasks: `bake.rb`
- Tests: `test/`
- Site config: `site.toml`, `projects.toml`
- Published posts: `posts/YYYY/MM/*.md`
- Static and renderable public content: `public/`
- Draft posts: `public/drafts/`
- Generated HTML output: `www/` (safe to delete/regenerate)
- Generated Gemini output: `gemini/` (safe to delete/regenerate)
- Gemini protocol reference docs: `gemini-docs/`
- CI: `.github/workflows/ci.yml` (runs coverage, lint, and debug build)

Keep new code under the existing `Pressa` module structure (for example `lib/pressa/posts`, `lib/pressa/projects`, `lib/pressa/views`, `lib/pressa/config`, `lib/pressa/utils`) and add matching tests under `test/`.

## Setup, Build, Test, and Development Commands
- Use `rbenv exec` for Ruby commands in this repository (for example `rbenv exec bundle exec ...`) to ensure the project Ruby version is used.
- `bin/bootstrap`: install prerequisites and gems (uses `rbenv` when available).
- `rbenv exec bundle exec bake debug`: build HTML for `http://localhost:8000` into `www/`.
- `rbenv exec bundle exec bake serve`: serve `www/` via WEBrick on port 8000.
- `rbenv exec bundle exec bake watch target=debug`: Linux-only autorebuild loop (`inotifywait` required).
- `rbenv exec bundle exec bake mudge|beta|release`: build HTML with environment-specific base URLs.
- `rbenv exec bundle exec bake gemini`: build Gemini capsule into `gemini/`.
- `rbenv exec bundle exec bake publish_beta`: build and rsync `www/` to beta host.
- `rbenv exec bundle exec bake publish_gemini`: build and rsync `gemini/` to production host.
- `rbenv exec bundle exec bake publish`: build and rsync both HTML and Gemini to production.
- `rbenv exec bundle exec bake clean`: remove `www/` and `gemini/`.
- `rbenv exec bundle exec bake test`: run test suite.
- `rbenv exec bundle exec bake guard`: run Guard for continuous testing.
- `rbenv exec bundle exec bake lint`: lint code with StandardRB.
- `rbenv exec bundle exec bake lint_fix`: auto-fix lint issues.
- `rbenv exec bundle exec bake coverage`: run tests and report `lib/` line coverage.
- `rbenv exec bundle exec bake coverage_regression baseline=merge-base`: compare coverage to a baseline and fail on regression (override `baseline` as needed).

## Draft Workflow
- `rbenv exec bundle exec bake new_draft "Post Title"` creates `public/drafts/<slug>.md`.
- `rbenv exec bundle exec bake drafts` lists available drafts.
- `rbenv exec bundle exec bake publish_draft public/drafts/<slug>.md` moves draft to `posts/YYYY/MM/` and updates `Date` and `Timestamp`.

## Content and Metadata Requirements
Posts must include YAML front matter. Required keys (enforced by `Pressa::Posts::PostMetadata`) are:

- `Title`
- `Author`
- `Date`
- `Timestamp`

Optional keys include `Tags`, `Link`, `Scripts`, and `Styles`.

## Coding Style & Naming Conventions
- Ruby (see `.ruby-version`).
- Follow idiomatic Ruby style and keep code `bake lint`-clean.
- Use 2-space indentation and descriptive `snake_case` names for methods/variables, `UpperCamelCase` for classes/modules.
- Prefer small, focused classes for plugins, views, renderers, and config loaders.
- Do not hand-edit generated files in `www/` or `gemini/`.

## Testing Guidelines
- Use Minitest under `test/` (for example `test/posts`, `test/config`, `test/views`).
- Add regression tests for parser, rendering, feed, and generator behavior changes.
- Before submitting, run:
  - `rbenv exec bundle exec bake test`
  - `rbenv exec bundle exec bake coverage`
  - `rbenv exec bundle exec bake lint`
  - `rbenv exec bundle exec bake debug`

## Commit & Pull Request Guidelines
- Use concise, imperative commit subjects (history examples: `Fix internal permalink regression in archives`).
- Keep commits scoped to one concern (generator logic, content, or deployment changes).
- In PRs, include motivation, verification commands run, and deployment impact.
- Include screenshots when changing rendered layout/CSS output.

## Deployment & Security Notes
- Deployment is defined in `bake.rb` via rsync over SSH.
- Current publish host is `mudge` with:
  - production HTML: `/var/www/samhuri.net/public`
  - beta HTML: `/var/www/beta.samhuri.net/public`
  - production Gemini: `/var/gemini/samhuri.net`
- `bake publish` deploys both HTML and Gemini to production.
- Validate `www/` and `gemini/` before publishing to avoid shipping stale assets.
- Never commit credentials, SSH keys, or other secrets.
