require "test_helper"
require "pressa/posts/metadata"

class Pressa::LinkPostTest < Minitest::Test
  def setup
    @now = Time.new(2026, 6, 7, 14, 30, 0, "-07:00")
  end

  def build(**overrides)
    defaults = {
      title: "Magical Wristband",
      link: "https://example.net/magicband",
      now: @now,
      author: "Sami Samhuri"
    }
    Pressa::LinkPost.build(**defaults.merge(overrides))
  end

  def test_target_path_uses_slug_and_year_month
    post = build
    assert_equal("posts/2026/06/magical-wristband.md", post.target_path)
    assert_equal("magical-wristband.md", post.filename)
  end

  def test_front_matter_is_parseable_and_complete
    post = build(body: "Disney's take on the wearable.", tags: "gear, tech")
    meta = Pressa::Posts::PostMetadata.parse(post.content)

    assert_equal("Magical Wristband", meta.title)
    assert_equal("Sami Samhuri", meta.author)
    assert_equal("7th June, 2026", meta.formatted_date)
    assert_equal("https://example.net/magicband", meta.link)
    assert_equal(%w[gear tech], meta.tags)
    assert_includes(post.content, "Disney's take on the wearable.")
  end

  def test_timestamp_is_iso8601_with_offset
    post = build
    meta = Pressa::Posts::PostMetadata.parse(post.content)
    assert_equal("2026-06-07T14:30:00-07:00", meta.date.strftime("%Y-%m-%dT%H:%M:%S%:z"))
  end

  def test_title_with_special_characters_round_trips
    weird = %(Fish: "And" \\ Chips)
    post = build(title: weird)
    meta = Pressa::Posts::PostMetadata.parse(post.content)
    assert_equal(weird, meta.title)
  end

  def test_tags_omitted_when_blank
    post = build(tags: "  ")
    refute_includes(post.content, "Tags:")
  end

  def test_body_optional_for_link_only_posts
    post = build(body: nil)
    meta = Pressa::Posts::PostMetadata.parse(post.content)
    assert_equal("https://example.net/magicband", meta.link)
  end

  def test_blank_title_raises
    error = assert_raises(Pressa::LinkPost::Error) { build(title: "  ") }
    assert_match(/title/i, error.message)
  end

  def test_title_with_only_symbols_raises
    assert_raises(Pressa::LinkPost::Error) { build(title: "!!!") }
  end

  def test_blank_link_raises
    error = assert_raises(Pressa::LinkPost::Error) { build(link: "  ") }
    assert_match(/link/i, error.message)
  end
end
