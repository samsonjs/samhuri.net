require "test_helper"

# Highlighting moved into the browser, so a code fence tagged with a language
# MicroLighter has no grammar for fails silently: the block just renders grey.
# These tests are the tripwire for that.
class Pressa::SyntaxHighlightingTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  GRAMMARS_DIR = File.join(ROOT, "public/js/microlighter/grammars")
  RUNTIME = File.join(ROOT, "public/js/microlighter/microlighter.min.js")

  # Baked into microlighter.min.js; kept here so a fence tagged `sh` or `yml`
  # isn't reported as missing.
  ALIASES = {
    "docker" => "dockerfile",
    "gql" => "graphql",
    "js" => "javascript",
    "jsx" => "javascript",
    "md" => "markdown",
    "py" => "python",
    "rb" => "ruby",
    "sass" => "scss",
    "sh" => "bash",
    "shell" => "bash",
    "ts" => "typescript",
    "yml" => "yaml",
    "zsh" => "bash"
  }.freeze

  # Grammars this repo maintains in vendor/microlighter, because upstream has
  # no equivalent. See bin/vendor-microlighter and bin/check-grammars.
  LOCAL_GRAMMARS = %w[bat conf haskell lisp scheme].freeze

  def fenced_languages
    @fenced_languages ||= Dir.glob("#{ROOT}/{posts,public}/**/*.md").flat_map do |path|
      File.read(path).scan(/^```([A-Za-z0-9_+-]+)$/).flatten
    end.map(&:downcase).uniq.sort
  end

  def test_every_fenced_language_has_a_grammar
    missing = fenced_languages.reject do |language|
      File.exist?(File.join(GRAMMARS_DIR, "#{ALIASES.fetch(language, language)}.js"))
    end

    assert_empty(
      missing,
      "No MicroLighter grammar for #{missing.join(", ")}. Add one under " \
      "vendor/microlighter/grammars and run bin/vendor-microlighter."
    )
  end

  def test_local_grammars_survive_a_revendor
    LOCAL_GRAMMARS.each do |language|
      overlay = File.join(ROOT, "vendor/microlighter/grammars/#{language}.js")
      installed = File.join(GRAMMARS_DIR, "#{language}.js")

      assert(File.exist?(overlay), "#{language} is missing from the vendor overlay")
      assert_equal(
        File.read(overlay),
        File.read(installed),
        "#{language}.js in public/ has drifted from vendor/; run bin/vendor-microlighter"
      )
    end
  end

  def test_the_site_loads_the_runtime_and_theme
    assert(File.exist?(RUNTIME), "MicroLighter runtime is not vendored")

    site = Pressa.create_site(source_path: ROOT)
    runtime = site.scripts.find { it.src.include?("microlighter") }

    refute_nil(runtime, "site.toml does not load MicroLighter")
    assert_equal("module", runtime.type)
    assert_includes(site.styles.map(&:href), "/css/syntax.css")

    theme = File.read(File.join(ROOT, "public/css/syntax.css"))
    assert_includes(theme, %([data-syntax-theme="solarized-light"]))
    assert_includes(theme, "::highlight(")

    # style.css owns the code block background in both appearances. A theme
    # that paints the pre itself overrides it, which is how gruvbox's cream
    # turned code blocks yellow in light mode. Comments are stripped first so
    # the note explaining that doesn't trip the check.
    rules = theme.gsub(%r{/\*.*?\*/}m, "")

    refute_includes(rules, "pre:has(code)")
    refute_includes(rules, "--syntax-background")
    refute_includes(rules, "--syntax-foreground")
  end
end
