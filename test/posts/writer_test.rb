require "test_helper"
require "tmpdir"

class Pressa::Posts::PostWriterTest < Minitest::Test
  def site
    @site ||= Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net"
    )
  end

  def posts_by_year
    @posts_by_year ||= begin
      link_post = Pressa::Posts::Post.new(
        slug: "link-post",
        title: "Linked",
        author: "Sami Samhuri",
        date: DateTime.parse("2025-11-05T10:00:00-08:00"),
        formatted_date: "5th November, 2025",
        link: "https://example.net/linked",
        body: "<p>linked body</p>",
        excerpt: "linked body...",
        path: "/posts/2025/11/link-post"
      )
      regular_post = Pressa::Posts::Post.new(
        slug: "regular-post",
        title: "Regular",
        author: "Sami Samhuri",
        date: DateTime.parse("2024-10-01T10:00:00-07:00"),
        formatted_date: "1st October, 2024",
        body: "<p>regular body</p>",
        excerpt: "regular body...",
        path: "/posts/2024/10/regular-post",
        tags: ["ruby", "rails"]
      )

      nov_posts = Pressa::Posts::MonthPosts.new(
        month: Pressa::Posts::Month.new(name: "November", number: 11, padded: "11"),
        posts: [link_post]
      )
      oct_posts = Pressa::Posts::MonthPosts.new(
        month: Pressa::Posts::Month.new(name: "October", number: 10, padded: "10"),
        posts: [regular_post]
      )

      Pressa::Posts::PostsByYear.new(
        by_year: {
          2025 => Pressa::Posts::YearPosts.new(year: 2025, by_month: {11 => nov_posts}),
          2024 => Pressa::Posts::YearPosts.new(year: 2024, by_month: {10 => oct_posts})
        }
      )
    end
  end

  def writer
    @writer ||= Pressa::Posts::PostWriter.new(site:, posts_by_year:)
  end

  def test_write_posts_writes_each_post_page
    Dir.mktmpdir do |dir|
      writer.write_posts(target_path: dir)

      regular = File.join(dir, "posts/2024/10/regular-post/index.html")
      linked = File.join(dir, "posts/2025/11/link-post/index.html")

      assert(File.exist?(regular))
      assert(File.exist?(linked))
      assert_includes(File.read(regular), "Regular")
      assert_includes(File.read(linked), "→ Linked")
    end
  end

  def test_write_recent_posts_writes_index_page
    Dir.mktmpdir do |dir|
      writer.write_recent_posts(target_path: dir, limit: 1)

      index_path = File.join(dir, "index.html")
      assert(File.exist?(index_path))
      html = File.read(index_path)
      assert_includes(html, "Linked")
      refute_includes(html, "Regular")
    end
  end

  def test_write_posts_archive_writes_posts_index
    Dir.mktmpdir do |dir|
      writer.write_posts_archive(target_path: dir)

      posts_path = File.join(dir, "posts/index.html")
      assert(File.exist?(posts_path))
      html = File.read(posts_path)
      assert_includes(html, "Posts")
      assert_includes(html, "https://samhuri.net/posts/2025/")
    end
  end

  def test_write_year_indexes_writes_each_year_index
    Dir.mktmpdir do |dir|
      writer.write_year_indexes(target_path: dir)

      path_2025 = File.join(dir, "posts/2025/index.html")
      path_2024 = File.join(dir, "posts/2024/index.html")
      assert(File.exist?(path_2025))
      assert(File.exist?(path_2024))
      assert_includes(File.read(path_2025), "November")
    end
  end

  def test_write_month_rollups_writes_each_month_index
    Dir.mktmpdir do |dir|
      writer.write_month_rollups(target_path: dir)

      nov = File.join(dir, "posts/2025/11/index.html")
      oct = File.join(dir, "posts/2024/10/index.html")
      assert(File.exist?(nov))
      assert(File.exist?(oct))
      assert_includes(File.read(nov), "November 2025")
      assert_includes(File.read(oct), "October 2024")
    end
  end

  def test_write_tags_index_writes_tags_with_counts
    Dir.mktmpdir do |dir|
      writer.write_tags_index(target_path: dir)

      index_path = File.join(dir, "tags/index.html")
      assert(File.exist?(index_path))
      html = File.read(index_path)
      assert_includes(html, "https://samhuri.net/tags/ruby/")
      assert_includes(html, "rails")
      assert_includes(html, "(1)")
    end
  end

  def test_write_tag_pages_writes_each_tag_page
    Dir.mktmpdir do |dir|
      writer.write_tag_pages(target_path: dir)

      ruby_path = File.join(dir, "tags/ruby/index.html")
      assert(File.exist?(ruby_path))
      html = File.read(ruby_path)
      assert_includes(html, "Tag: ruby")
      assert_includes(html, "Regular")
      refute_includes(html, "Linked")
    end
  end
end
