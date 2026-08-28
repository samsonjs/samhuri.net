require "test_helper"
require "fileutils"
require "tmpdir"

class Pressa::Posts::PostRepoTest < Minitest::Test
  def repo
    @repo ||= Pressa::Posts::PostRepo.new
  end

  def test_read_posts_reads_and_organizes_posts_by_year_and_month
    Dir.mktmpdir do |tmpdir|
      posts_dir = File.join(tmpdir, "posts", "2025", "11")
      FileUtils.mkdir_p(posts_dir)

      post_content = <<~MARKDOWN
        ---
        Title: Shredding in November
        Author: Shaun White
        Date: 5th November, 2025
        Timestamp: 2025-11-05T10:00:00-08:00
        ---

        Had an epic day at Whistler. The powder was deep and the lines were short.
      MARKDOWN

      File.write(File.join(posts_dir, "shredding.md"), post_content)

      posts_by_year = repo.read_posts(File.join(tmpdir, "posts"))

      assert_equal(1, posts_by_year.all_posts.length)

      post = posts_by_year.all_posts.first
      assert_equal("Shredding in November", post.title)
      assert_equal("Shaun White", post.author)
      assert_equal("shredding", post.slug)
      assert_equal(2025, post.year)
      assert_equal(11, post.month)
      assert_equal("/posts/2025/11/shredding", post.path)
    end
  end

  def test_read_posts_generates_excerpts_from_post_content
    Dir.mktmpdir do |tmpdir|
      posts_dir = File.join(tmpdir, "posts", "2025", "11")
      FileUtils.mkdir_p(posts_dir)

      post_content = <<~MARKDOWN
        ---
        Title: Test Post
        Author: Greg Graffin
        Date: 5th November, 2025
        Timestamp: 2025-11-05T10:00:00-08:00
        ---

        This is a test post with some content. It should generate an excerpt.

        ![Image](image.png)

        More content with a [link](https://example.net).
      MARKDOWN

      File.write(File.join(posts_dir, "test.md"), post_content)

      posts_by_year = repo.read_posts(File.join(tmpdir, "posts"))
      post = posts_by_year.all_posts.first

      assert_includes(post.excerpt, "test post")
      refute_includes(post.excerpt, "![")
      assert_includes(post.excerpt, "link")
      refute_includes(post.excerpt, "[link]")
    end
  end

  def test_read_posts_merges_multiple_posts_in_same_month
    Dir.mktmpdir do |tmpdir|
      posts_dir = File.join(tmpdir, "posts", "2025", "11")
      FileUtils.mkdir_p(posts_dir)

      File.write(File.join(posts_dir, "first.md"), <<~MARKDOWN)
        ---
        Title: First Post
        Author: Sami Samhuri
        Date: 5th November, 2025
        Timestamp: 2025-11-05T10:00:00-08:00
        ---

        First
      MARKDOWN

      File.write(File.join(posts_dir, "second.md"), <<~MARKDOWN)
        ---
        Title: Second Post
        Author: Sami Samhuri
        Date: 6th November, 2025
        Timestamp: 2025-11-06T10:00:00-08:00
        ---

        Second
      MARKDOWN

      posts_by_year = repo.read_posts(File.join(tmpdir, "posts"))
      month_posts = posts_by_year.by_year.fetch(2025).by_month.fetch(11)

      assert_equal(2, month_posts.posts.length)
      assert_equal(["Second Post", "First Post"], month_posts.sorted_posts.map(&:title))
    end
  end

  def test_build_post_builds_a_post_from_content_without_touching_the_filesystem
    content = <<~MARKDOWN
      ---
      Title: Tree Well Protocol
      Author: Jane Doe
      Date: 7th June, 2026
      Timestamp: 2026-06-07T14:30:00-07:00
      Tags: snowboarding, safety
      Link: https://powder.example.net/tree-wells
      ---

      Never ride alone in deep snow.
    MARKDOWN

    post = repo.build_post(content:, slug: "tree-well-protocol")

    assert_equal("Tree Well Protocol", post.title)
    assert_equal("Jane Doe", post.author)
    assert_equal("tree-well-protocol", post.slug)
    assert_equal("/posts/2026/06/tree-well-protocol", post.path)
    assert_equal(["snowboarding", "safety"], post.tags)
    assert_equal("https://powder.example.net/tree-wells", post.link)
    assert_includes(post.body, "<p>Never ride alone in deep snow.</p>")
    assert_equal("Never ride alone in deep snow.\n", post.markdown_body)
  end

  def test_read_posts_and_build_post_agree
    Dir.mktmpdir do |tmpdir|
      posts_dir = File.join(tmpdir, "posts", "2026", "06")
      FileUtils.mkdir_p(posts_dir)

      content = <<~MARKDOWN
        ---
        Title: Lift Line Notes
        Author: Fat Mike
        Date: 7th June, 2026
        Timestamp: 2026-06-07T14:30:00-07:00
        ---

        Chairlift conversations, collected.
      MARKDOWN

      File.write(File.join(posts_dir, "lift-line-notes.md"), content)
      from_disk = repo.read_posts(File.join(tmpdir, "posts")).all_posts.first

      assert_equal(from_disk.to_h, repo.build_post(content:, slug: "lift-line-notes").to_h)
    end
  end
end
