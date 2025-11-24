# Syntax Highlighting with Rouge

Pressa uses Rouge for syntax highlighting through Kramdown. Your posts should already work correctly with Rouge if they use standard Markdown code fences.

## Supported Formats

### GitHub Flavored Markdown (Recommended)

````markdown
```ruby
def hello
  puts "Hello, World!"
end
```
````

### Kramdown Syntax

````markdown
~~~ ruby
def hello
  puts "Hello, World!"
end
~~~
````

### With Line Numbers (if needed)

You can enable line numbers in the Kramdown configuration, but by default Pressa has them disabled for cleaner output.

## Supported Languages

Rouge supports 200+ languages. Common ones include:

- `ruby`
- `javascript` / `js`
- `python` / `py`
- `swift`
- `bash` / `shell`
- `html`
- `css`
- `sql`
- `yaml` / `yml`
- `json`
- `markdown` / `md`

Full list: https://github.com/rouge-ruby/rouge/wiki/List-of-supported-languages-and-lexers

## CSS Styling

Rouge generates syntax highlighting by wrapping code elements with `<span>` tags that have semantic class names.

Example output:
```html
<div class="language-ruby highlighter-rouge">
  <span class="k">class</span> <span class="nc">Post</span>
  <span class="k">end</span>
</div>
```

### CSS Classes

Common classes used by Rouge:

- `.k` - Keyword
- `.nc` - Class name
- `.nf` - Function name
- `.s`, `.s1`, `.s2` - Strings
- `.c`, `.c1` - Comments
- `.n` - Name/identifier
- `.o` - Operator
- `.p` - Punctuation

### Generating CSS

You can generate Rouge CSS themes with:

```bash
# List available themes
bundle exec rougify help style

# Generate CSS for a theme
bundle exec rougify style github > public/css/syntax.css
bundle exec rougify style monokai > public/css/syntax-dark.css
```

Popular themes:
- `github` - GitHub's light theme
- `monokai` - Dark theme
- `base16` - Base16 color scheme
- `thankful_eyes` - Easy on the eyes
- `tulip` - Colorful

## Checking Your Posts

Your existing posts should work fine if they use:
1. Standard Markdown code fences with language specifiers
2. HTML `<pre><code>` blocks (will work but won't be highlighted)

To check a specific post:

```bash
grep -A 5 '```' posts/2025/11/your-post.md
```

## Configuration in Pressa

Syntax highlighting is configured in `lib/posts/repo.rb` and `lib/utils/markdown_renderer.rb`:

```ruby
Kramdown::Document.new(
  markdown,
  input: 'GFM',
  syntax_highlighter: 'rouge',
  syntax_highlighter_opts: {
    line_numbers: false,  # Change to true if you want line numbers
    wrap: true            # Leave true so Rouge emits <pre><code> blocks
  }
).to_html
```

## Testing

You can test syntax highlighting with the provided test post:

```bash
bundle exec bake debug
bundle exec bake serve
# Open http://localhost:8000 in browser
```

The test post at `test-site/posts/2025/11/test-post.md` includes a Ruby code example with syntax highlighting.

## Migration Notes

If you're migrating from Swift/Ink, both use similar Markdown parsers, so your code blocks should "just work." The main difference is:

- **Ink**: Built-in syntax highlighting (uses its own system)
- **Rouge**: External gem, more themes, more languages, generates semantic HTML

Rouge output is more flexible because it generates plain HTML with classes, allowing you to change themes by just swapping CSS files.
