require "test_helper"

class Pressa::Posts::ModelsTest < Minitest::Test
  def regular_post
    @regular_post ||= Pressa::Posts::Post.new(
      slug: "regular",
      title: "Regular",
      author: "Sami Samhuri",
      date: DateTime.parse("2025-11-05T10:00:00-08:00"),
      formatted_date: "5th November, 2025",
      body: "<p>regular</p>",
      excerpt: "regular...",
      path: "/posts/2025/11/regular"
    )
  end

  def link_post
    @link_post ||= Pressa::Posts::Post.new(
      slug: "linked",
      title: "Linked",
      author: "Sami Samhuri",
      date: DateTime.parse("2024-10-01T10:00:00-07:00"),
      formatted_date: "1st October, 2024",
      link: "https://example.net/post",
      body: "<p>linked</p>",
      excerpt: "linked...",
      path: "/posts/2024/10/linked"
    )
  end

  def test_post_helpers_report_date_parts_and_link_state
    assert_equal(2025, regular_post.year)
    assert_equal(11, regular_post.month)
    assert_equal("November", regular_post.formatted_month)
    assert_equal("11", regular_post.padded_month)
    refute(regular_post.link_post?)
    assert(link_post.link_post?)
  end

  def test_month_from_date_creates_expected_values
    month = Pressa::Posts::Month.from_date(DateTime.parse("2025-02-14T08:00:00-08:00"))
    assert_equal("February", month.name)
    assert_equal(2, month.number)
    assert_equal("02", month.padded)
  end

  def test_month_posts_sorted_posts_returns_descending_by_date
    month_posts = Pressa::Posts::MonthPosts.new(
      month: Pressa::Posts::Month.new(name: "November", number: 11, padded: "11"),
      posts: [link_post, regular_post]
    )

    assert_equal([regular_post, link_post], month_posts.sorted_posts)
  end

  def test_year_posts_and_posts_by_year_sorting_helpers
    oct_posts = Pressa::Posts::MonthPosts.new(
      month: Pressa::Posts::Month.new(name: "October", number: 10, padded: "10"),
      posts: [link_post]
    )
    nov_posts = Pressa::Posts::MonthPosts.new(
      month: Pressa::Posts::Month.new(name: "November", number: 11, padded: "11"),
      posts: [regular_post]
    )

    year_2025 = Pressa::Posts::YearPosts.new(year: 2025, by_month: {11 => nov_posts, 10 => oct_posts})
    year_2024 = Pressa::Posts::YearPosts.new(year: 2024, by_month: {10 => oct_posts})
    posts_by_year = Pressa::Posts::PostsByYear.new(by_year: {2024 => year_2024, 2025 => year_2025})

    assert_equal([11, 10], year_2025.sorted_months.map { |mp| mp.month.number })
    assert_equal([regular_post, link_post], year_2025.all_posts)
    assert_equal([2025, 2024], posts_by_year.sorted_years)
    assert_equal(2024, posts_by_year.earliest_year)
    assert_equal(3, posts_by_year.all_posts.length)
    assert_equal([regular_post], posts_by_year.recent_posts(1))
  end

  def test_posts_by_year_earliest_year_is_nil_for_empty_collection
    posts_by_year = Pressa::Posts::PostsByYear.new(by_year: {})
    assert_nil(posts_by_year.earliest_year)
  end
end
