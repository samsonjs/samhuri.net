require "test_helper"

class Pressa::Posts::PostMetadataTest < Minitest::Test
  def test_parse_parses_valid_yaml_front_matter
    content = <<~MARKDOWN
      ---
      Title: Test Post
      Author: Trent Reznor
      Date: 5th November, 2025
      Timestamp: 2025-11-05T10:00:00-08:00
      Tags: Ruby, Testing
      Scripts: highlight.js
      Styles: code.css
      Link: https://example.net/external
      ---

      This is the post body.
    MARKDOWN

    metadata = Pressa::Posts::PostMetadata.parse(content)

    assert_equal("Test Post", metadata.title)
    assert_equal("Trent Reznor", metadata.author)
    assert_equal("5th November, 2025", metadata.formatted_date)
    assert_equal(2025, metadata.date.year)
    assert_equal(11, metadata.date.month)
    assert_equal(5, metadata.date.day)
    assert_equal("https://example.net/external", metadata.link)
    assert_equal(["Ruby", "Testing"], metadata.tags)
    assert_equal(["js/highlight.js"], metadata.scripts.map(&:src))
    assert_equal(["css/code.css"], metadata.styles.map(&:href))
  end

  def test_parse_raises_error_when_required_fields_are_missing
    content = <<~MARKDOWN
      ---
      Title: Incomplete Post
      ---

      Body content
    MARKDOWN

    error = assert_raises(StandardError) { Pressa::Posts::PostMetadata.parse(content) }
    assert_match(/Missing required fields/, error.message)
  end

  def test_parse_handles_posts_without_optional_fields
    content = <<~MARKDOWN
      ---
      Title: Simple Post
      Author: Fat Mike
      Date: 1st January, 2025
      Timestamp: 2025-01-01T12:00:00-08:00
      ---

      Simple content
    MARKDOWN

    metadata = Pressa::Posts::PostMetadata.parse(content)

    assert_equal([], metadata.tags)
    assert_equal([], metadata.scripts)
    assert_equal([], metadata.styles)
    assert_nil(metadata.link)
  end
end
