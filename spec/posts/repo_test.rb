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
end
