# Repository Guidelines

## Project Structure & Module Organization
This repository is a Ruby static-site generator (Pressa) that outputs both HTML and Gemini formats.

- Generator code: `lib/pressa/` (entrypoint: `lib/pressa.rb`)
- Web app: `lib/pressa/web/` (Sinatra app, jobs, drafts, preview) with templates and assets in `web/`
- Publish scripts: `bin/post-link`, `bin/publish-draft`, `bin/preview-link`, sharing `bin/lib/common.sh`
- Build/publish/draft tasks: `bake.rb` (delegating to helpers under `lib/pressa/`)
- Tests: `test/`
- Site config: `site.toml`, `projects.toml`
- Published posts: `posts/YYYY/MM/*.md`
- Static and renderable public content: `public/`
- Draft posts: `public/drafts/`
- Generated HTML output: `www/` (safe to delete/regenerate)
- Generated Gemini output: `gemini/` (safe to delete/regenerate)
- Legacy static.samhuri.net assets: `static/` (checked in, **not** generated — do not delete). Published by `bake publish_static` to `/var/www/static.samhuri.net/public` on mudge, which Caddy serves over both http and https. Only assets still referenced anywhere are kept: the four `Screen Shot 2015-*.png` plus `screenshot_2015-05-08-*.png` linked from the archived tweets under `public/tweets/`, and `jazzy.png` which is embedded on GitHub. The other 120 files from the old S3 bucket were dropped; `s3://static.samhuri.net` still holds them all if one is ever needed.
- Gemini protocol reference docs: `gemini-docs/`
- CI: `.github/workflows/ci.yml` (runs coverage, lint, and debug build)

Keep new code under the existing `Pressa` module structure (for example `lib/pressa/posts`, `lib/pressa/projects`, `lib/pressa/views`, `lib/pressa/config`, `lib/pressa/utils`) and add matching tests under `test/`.

## Setup, Build, Test, and Development Commands
- Ruby commands run directly (`bundle exec ...`); `rv` manages the pinned version via `.ruby-version`, no exec wrapper needed.
- `bin/bootstrap`: install prerequisites and gems via `rv`.
- `bundle exec bake debug`: build HTML for `http://localhost:8000` into `www/`.
- `bundle exec bake serve`: serve `www/` via WEBrick on port 8000.
- `bundle exec bake web`: run the Pressa web app on `http://localhost:1112`.
- `bundle exec bake watch target=debug`: Linux-only autorebuild loop (`inotifywait` required).
- `bundle exec bake mudge|beta|release`: build HTML with environment-specific base URLs.
- `bundle exec bake gemini`: build Gemini capsule into `gemini/`.
- `bundle exec bake publish_beta`: build and rsync `www/` to beta host.
- `bundle exec bake publish_gemini`: build and rsync `gemini/` to production host.
- `bundle exec bake publish`: build and rsync both HTML and Gemini to production.
- `bundle exec bake clean`: remove `www/` and `gemini/`.
- `bundle exec bake test`: run test suite.
- `bundle exec bake guard`: run Guard for continuous testing.
- `bundle exec bake lint`: lint code with StandardRB.
- `bundle exec bake lint_fix`: auto-fix lint issues.
- `bundle exec bake coverage`: run tests and report `lib/` line coverage.
- `bundle exec bake coverage_regression baseline=merge-base`: compare coverage to a baseline and fail on regression (override `baseline` as needed).

## Draft Workflow
- `bundle exec bake new_draft "Post Title"` creates `public/drafts/<slug>.md`.
- `bundle exec bake drafts` lists available drafts.
- `bundle exec bake publish_draft public/drafts/<slug>.md` moves draft to `posts/YYYY/MM/` and updates `Date` and `Timestamp`.
- `bin/publish-draft <slug>` does the whole thing on the publish host: commit pending edits, pull, `bake publish_draft`, commit, push, `bake publish`.

## Web App
`lib/pressa/web/` is a Sinatra app that owns posting a link, drafts, and preview. It runs on mudge as `pressa-web.service` on `127.0.0.1:1112`, published by Caddy at `http://mudge:7777` and restricted to Tailscale source IPs, and is served by `web/bin/start` (puma, threads only).

- It drives `bin/post-link` and `bin/publish-draft` rather than reimplementing the publish flow, and renders previews through `Posts::PostWriter#post_html` and `Posts::GeminiWriter#post_content` — the same code the build uses.
- Publishing runs inline via `Web::JobRunner`, which drives the script and collects its output for the page. A publish measures about five seconds, most of it the two GitHub round trips, so there is nothing for a queue to do.
- Only one publish may touch the checkout at a time. The `flock` in `bin/lib/common.sh` enforces that across processes, so the phone Shortcut over SSH and the web app can't collide; a blocked publish exits 75 (EX_TEMPFAIL) and the app turns that into a 409 telling you to try again.
- Sinatra and puma live in this repo's Gemfile on purpose. A separate `web/Gemfile` would leave `BUNDLE_GEMFILE` pointing at the wrong one inside `bin/post-link`'s `bundle exec bake`.

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
- `test/bin/publish_scripts_test.rb` runs `bin/post-link` and `bin/publish-draft` for real, against a temporary git repo with a real remote and a stubbed `bake.rb`. It's the slowest file in the suite (~3s of the ~6s total) and it's there because git sequencing bugs in those scripts are invisible to everything else.
- Add regression tests for parser, rendering, feed, and generator behavior changes.
- Before submitting, run:
  - `bundle exec bake test`
  - `bundle exec bake coverage`
  - `bundle exec bake lint`
  - `bundle exec bake debug`

## Commit & Pull Request Guidelines
- Use concise, imperative commit subjects (history examples: `Fix internal permalink regression in archives`).
- Keep commits scoped to one concern (generator logic, content, or deployment changes).
- In PRs, include motivation, verification commands run, and deployment impact.
- Include screenshots when changing rendered layout/CSS output.

## Deployment & Security Notes
- Publish tasks are defined in `bake.rb` via rsync over SSH.
- The web app is deployed from the `mudge.samhuri.net` repo (`config/systemd/pressa-web.service` and the Caddy vhost); the code lives here.
- Current publish host is `mudge` with:
  - production HTML: `/var/www/samhuri.net/public`
  - beta HTML: `/var/www/beta.samhuri.net/public`
  - production Gemini: `/var/gemini/samhuri.net`
- `bake publish` deploys both HTML and Gemini to production.
- Validate `www/` and `gemini/` before publishing to avoid shipping stale assets.
- Never commit credentials, SSH keys, or other secrets.
