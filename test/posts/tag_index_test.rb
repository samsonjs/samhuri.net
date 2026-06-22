require "test_helper"

class Pressa::Posts::TagIndexTest < Minitest::Test
  def post(slug:, year:, tags:)
    Pressa::Posts::Post.new(
      slug:,
      title: slug,
      author: "Sami Samhuri",
      date: DateTime.parse("#{year}-06-01T10:00:00-07:00"),
      formatted_date: "1st June, #{year}",
      body: "<p>#{slug}</p>",
      excerpt: "#{slug}...",
      path: "/posts/#{year}/06/#{slug}",
      tags:
    )
  end

  def posts
    [
      post(slug: "a", year: 2020, tags: ["ruby", "rails"]),
      post(slug: "b", year: 2020, tags: ["ruby"]),
      post(slug: "c", year: 2022, tags: ["swift"])
    ]
  end

  def tag_index
    @tag_index ||= Pressa::Posts::TagIndex.new(posts)
  end

  def test_counts_sorted_by_frequency_then_name
    assert_equal({"ruby" => 2, "rails" => 1, "swift" => 1}, tag_index.counts)
  end

  def test_posts_for_returns_matching_posts_newest_first
    assert_equal(["b", "a"], tag_index.posts_for("ruby").map(&:slug))
    assert_equal(["c"], tag_index.posts_for("swift").map(&:slug))
  end

  def test_years_returns_sorted_unique_years
    assert_equal([2020, 2022], tag_index.years)
  end

  def test_counts_by_tag_and_year_breaks_down_per_year
    assert_equal({2020 => 2}, tag_index.counts_by_tag_and_year["ruby"])
    assert_equal({2020 => 1}, tag_index.counts_by_tag_and_year["rails"])
    assert_equal({2022 => 1}, tag_index.counts_by_tag_and_year["swift"])
  end

  def test_slug_uses_drafts_slugify
    assert_equal("keyboard-shortcuts", tag_index.slug("keyboard shortcuts"))
  end
end
