# Pressa

A Ruby-based static site generator using Phlex for HTML generation. Built to replace the Swift-based generator for samhuri.net.

## Features

- **Plugin-based architecture** - Extensible system with PostsPlugin and ProjectsPlugin
- **Hierarchical post organization** - Posts organized by year/month
- **Markdown processing** - Kramdown with Rouge for syntax highlighting
- **Multiple output formats** - Individual posts, homepage, archives, year/month indexes
- **RSS & JSON feeds** - Both feeds with 30 most recent posts
- **Link posts** - Support for posts linking to external URLs
- **Phlex templates** - Type-safe HTML generation
- **dry-struct models** - Immutable data structures

## Requirements

- Ruby 3.4.1+
- Bundler

## Installation

```bash
bundle install
```

## Usage

### Build Commands

```bash
# Development build (localhost:8000)
bundle exec bake debug

# Start local server
bundle exec bake serve

# Build for staging
bundle exec bake beta
bundle exec bake publish_beta  # build + deploy

# Build for production
bundle exec bake release
bundle exec bake publish        # build + deploy
```

### Running Tests

```bash
# Run all specs
bundle exec bake test

# Run specs with Guard (auto-run on file changes)
bundle exec bake guard
```

### Linting

```bash
# Check code style
bundle exec bake lint

# Auto-fix style issues
bundle exec bake lint_fix
```

### CLI

```bash
# Build site
bin/pressa SOURCE TARGET [URL]

# Example
bin/pressa . www https://samhuri.net
```

### Migration Tools

```bash
# Convert front-matter from custom format to YAML
bin/convert-frontmatter posts/**/*.md

# Validate output comparison between Swift and Ruby
bin/validate-output www-swift www-ruby
```

See [SYNTAX_HIGHLIGHTING.md](SYNTAX_HIGHLIGHTING.md) for details on Rouge syntax highlighting.

## Project Structure

```
pressa/
├── lib/
│   ├── pressa.rb           # Main entry point
│   ├── site_generator.rb   # Orchestrator
│   ├── site.rb             # Site model (dry-struct)
│   ├── plugin.rb           # Plugin base class
│   ├── posts/              # PostsPlugin
│   │   ├── plugin.rb
│   │   ├── repo.rb         # Read/parse posts
│   │   ├── writer.rb       # Write HTML
│   │   ├── metadata.rb     # YAML front-matter parsing
│   │   ├── models.rb       # Post, PostsByYear, etc.
│   │   ├── json_feed.rb
│   │   └── rss_feed.rb
│   ├── projects/           # ProjectsPlugin
│   │   ├── plugin.rb
│   │   └── models.rb
│   ├── views/              # Phlex templates
│   │   ├── layout.rb       # Base layout
│   │   ├── post_view.rb
│   │   ├── recent_posts_view.rb
│   │   ├── archive_view.rb
│   │   └── ...
│   └── utils/
│       ├── file_writer.rb
│       └── markdown_renderer.rb
├── bin/
│   └── pressa              # CLI executable
├── spec/                   # RSpec tests
└── bake.rb                 # Build tasks
```

## Content Structure

### Posts

Posts must be in `/posts/YYYY/MM/` with YAML front-matter:

```yaml
---
Title: Post Title
Author: Author Name
Date: 11th November, 2025
Timestamp: 2025-11-11T14:00:00-08:00
Tags: Ruby, Phlex            # Optional
Link: https://example.net    # Optional (for link posts)
Scripts: highlight.js        # Optional
Styles: code.css             # Optional
---

Post content in Markdown...
```

### Output Structure

```
www/
├── index.html              # Recent posts (10 most recent)
├── posts/
│   ├── index.html          # Archive page
│   ├── YYYY/
│   │   ├── index.html      # Year index
│   │   └── MM/
│   │       ├── index.html  # Month rollup
│   │       └── slug/
│   │           └── index.html  # Individual post
├── projects/
│   ├── index.html
│   └── project-name/
│       └── index.html
├── feed.json               # JSON Feed 1.1
├── feed.xml                # RSS 2.0
└── [static files from public/]
```

## Tech Stack

- **Ruby**: 3.4.1
- **Phlex**: 2.3 - HTML generation
- **Kramdown**: 2.5 - Markdown parsing
- **kramdown-parser-gfm**: 1.1 - GitHub Flavored Markdown
- **Rouge**: 4.6 - Syntax highlighting
- **dry-struct**: 1.8 - Immutable data models
- **Builder**: 3.3 - XML/RSS generation
- **Bake**: 0.20+ - Task runner
- **RSpec**: 3.13 - Testing
- **StandardRB**: 1.43 - Code linting

## Differences from Swift Version

1. **Language**: Ruby 3.4 vs Swift 6.1
2. **HTML generation**: Phlex vs Plot
3. **Markdown**: Kramdown+Rouge vs Ink
4. **Models**: dry-struct vs Swift structs
5. **Build system**: Bake vs Make
6. **Front-matter**: YAML vs custom format

## License

Personal project - not currently licensed for general use.
