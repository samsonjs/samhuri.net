require "test_helper"
require "tmpdir"

class Pressa::Config::SimpleTomlTest < Minitest::Test
  def parser
    @parser ||= Pressa::Config::SimpleToml.new
  end

  def test_load_file_raises_parse_error_for_missing_file
    Dir.mktmpdir do |dir|
      missing = File.join(dir, "missing.toml")

      error = assert_raises(Pressa::Config::ParseError) do
        Pressa::Config::SimpleToml.load_file(missing)
      end

      assert_match(/Config file not found/, error.message)
    end
  end

  def test_parse_supports_tables_array_tables_comments_and_multiline_arrays
    content = <<~TOML
      title = "samhuri # not a comment"
      [projects_plugin]
      scripts = ["js/a.js", "js/b.js"]
      styles = [
        "css/a.css",
        "css/b.css"
      ]

      [[projects]]
      name = "alpha"
      title = "Alpha"
      description = "Project Alpha"
      url = "https://github.com/samsonjs/alpha"

      [[projects]]
      name = "beta"
      title = "Beta"
      description = "Project Beta"
      url = "https://github.com/samsonjs/beta"
    TOML

    parsed = parser.parse(content)

    assert_equal("samhuri # not a comment", parsed["title"])
    assert_equal(["js/a.js", "js/b.js"], parsed.dig("projects_plugin", "scripts"))
    assert_equal(["css/a.css", "css/b.css"], parsed.dig("projects_plugin", "styles"))
    assert_equal(2, parsed["projects"].length)
    assert_equal("alpha", parsed["projects"][0]["name"])
    assert_equal("beta", parsed["projects"][1]["name"])
  end

  def test_parse_rejects_duplicate_keys
    content = <<~TOML
      author = "Sami"
      author = "Sam"
    TOML

    error = assert_raises(Pressa::Config::ParseError) { parser.parse(content) }
    assert_match(/Duplicate key 'author'/, error.message)
  end

  def test_parse_rejects_invalid_assignment
    error = assert_raises(Pressa::Config::ParseError) { parser.parse("invalid") }
    assert_match(/Invalid assignment/, error.message)
  end

  def test_parse_rejects_invalid_key_names
    error = assert_raises(Pressa::Config::ParseError) { parser.parse("bad-key = 1") }
    assert_match(/Invalid key/, error.message)
  end

  def test_parse_rejects_missing_value
    error = assert_raises(Pressa::Config::ParseError) { parser.parse("author =   ") }
    assert_match(/Missing value for key 'author'/, error.message)
  end

  def test_parse_rejects_invalid_table_paths
    error = assert_raises(Pressa::Config::ParseError) { parser.parse("[projects..plugin]") }
    assert_match(/Invalid table path/, error.message)
  end

  def test_parse_rejects_array_table_when_table_already_exists
    content = <<~TOML
      [projects]
      title = "single"
      [[projects]]
      title = "array item"
    TOML

    error = assert_raises(Pressa::Config::ParseError) { parser.parse(content) }
    assert_match(/Expected array for '\[\[projects\]\]'/, error.message)
  end

  def test_parse_rejects_nested_table_on_non_table_path
    content = <<~TOML
      projects = 1
      [projects.plugin]
      enabled = true
    TOML

    error = assert_raises(Pressa::Config::ParseError) { parser.parse(content) }
    assert_match(/Expected table path 'projects.plugin'/, error.message)
  end

  def test_parse_rejects_unsupported_value_types
    error = assert_raises(Pressa::Config::ParseError) do
      parser.parse("published_at = 2025-01-01")
    end

    assert_match(/Unsupported TOML value/, error.message)
  end

  def test_parse_rejects_unterminated_multiline_value
    content = <<~TOML
      scripts = [
        "a.js",
        "b.js"
    TOML

    error = assert_raises(Pressa::Config::ParseError) { parser.parse(content) }
    assert_match(/Unterminated value for key 'scripts'/, error.message)
  end

  def test_parse_ignores_comments_but_not_hashes_inside_strings
    content = <<~TOML
      url = "https://example.com/#anchor" # remove me
    TOML

    parsed = parser.parse(content)
    assert_equal("https://example.com/#anchor", parsed["url"])
  end

  def test_private_parsing_helpers_handle_escaped_quotes_inside_strings
    refute(parser.send(:needs_continuation?, "\"a\\\\\\\"b\""))

    stripped = parser.send(:strip_comments, "title = \"a\\\\\\\"b # keep\" # drop\n")
    assert_equal("title = \"a\\\\\\\"b # keep\" ", stripped)

    source = "\"a\\\\\\\"=b\" = 1"
    index = parser.send(:index_of_unquoted, source, "=")
    refute_nil(index)
    assert_equal("=", source[index])
    assert(index > source.rindex('"'))
  end
end
