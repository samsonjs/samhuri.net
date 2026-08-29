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
      Link: https://example.net/external
      Image: /images/blog/test-post.png
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
    assert_equal("/images/blog/test-post.png", metadata.image)
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
    assert_nil(metadata.link)
    assert_nil(metadata.image)
  end

  def test_parse_raises_error_when_front_matter_is_missing
    error = assert_raises(StandardError) do
      Pressa::Posts::PostMetadata.parse("just plain markdown")
    end

    assert_match(/No YAML front-matter found in post/, error.message)
  end

  # Every draft in this repo predates ISO timestamps; previewing one used to
  # blow up with "undefined method 'to_datetime' for an instance of Integer".
  def test_parses_a_bare_unix_timestamp
    content = <<~MARKDOWN
      ---
      Title: Security Through Obscurity
      Author: Sami Samhuri
      Date: 20th August, 2017
      Timestamp: 1503246688
      ---

      A common way to configure a Rails server.
    MARKDOWN

    metadata = Pressa::Posts::PostMetadata.parse(content)

    assert_equal(Time.at(1503246688).to_datetime, metadata.date)
  end
end
