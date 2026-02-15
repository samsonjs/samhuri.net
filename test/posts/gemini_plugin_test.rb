require "test_helper"
require "fileutils"
require "tmpdir"

class Pressa::Posts::GeminiPluginTest < Minitest::Test
  def site
    @site ||= Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net",
      output_format: "gemini",
      output_options: Pressa::GeminiOutputOptions.new(
        home_links: [
          Pressa::OutputLink.new(label: "About", href: "/about/"),
          Pressa::OutputLink.new(label: "Mastodon", href: "https://techhub.social/@sjs"),
          Pressa::OutputLink.new(label: "GitHub", href: "https://github.com/samsonjs"),
          Pressa::OutputLink.new(label: "Email", href: "mailto:sami@samhuri.net")
        ]
      )
    )
  end

  def test_render_writes_gemini_indexes_and_posts
    Dir.mktmpdir do |root|
      source_path = File.join(root, "source")
      target_path = File.join(root, "target")
      posts_dir = File.join(source_path, "posts", "2025", "11")
      FileUtils.mkdir_p(posts_dir)

      File.write(File.join(posts_dir, "markdown-only.md"), <<~MARKDOWN)
        ---
        Title: Markdown Only
        Author: Sami Samhuri
        Date: 5th November, 2025
        Timestamp: 2025-11-05T10:00:00-08:00
        ---

        This post has [one link](https://example.com) and no raw HTML.
      MARKDOWN

      File.write(File.join(posts_dir, "html-heavy.md"), <<~MARKDOWN)
        ---
        Title: HTML Heavy
        Author: Sami Samhuri
        Date: 6th November, 2025
        Timestamp: 2025-11-06T10:00:00-08:00
        ---

        <p>Raw HTML with <a href="https://example.org">a link</a>.</p>
      MARKDOWN

      File.write(File.join(posts_dir, "link-post.md"), <<~MARKDOWN)
        ---
        Title: Link Post
        Author: Sami Samhuri
        Date: 7th November, 2025
        Timestamp: 2025-11-07T10:00:00-08:00
        Link: https://example.net/story
        ---

        I wrote a short blurb about this interesting link.
      MARKDOWN

      plugin = Pressa::Posts::GeminiPlugin.new
      plugin.setup(site:, source_path:)
      plugin.render(site:, target_path:)

      assert(File.exist?(File.join(target_path, "index.gmi")))
      assert(File.exist?(File.join(target_path, "posts/index.gmi")))
      assert(File.exist?(File.join(target_path, "posts/feed.gmi")))
      refute(File.exist?(File.join(target_path, "posts/2025/index.gmi")))
      refute(File.exist?(File.join(target_path, "posts/2025/11/index.gmi")))

      markdown_post = File.join(target_path, "posts/2025/11/markdown-only/index.gmi")
      html_post = File.join(target_path, "posts/2025/11/html-heavy/index.gmi")

      assert(File.exist?(markdown_post))
      assert(File.exist?(html_post))

      index_text = File.read(File.join(target_path, "index.gmi"))
      markdown_text = File.read(markdown_post)
      html_text = File.read(html_post)
      archive_text = File.read(File.join(target_path, "posts/index.gmi"))
      feed_text = File.read(File.join(target_path, "posts/feed.gmi"))

      assert_includes(index_text, "=> /about/")
      assert_includes(index_text, "=> https://techhub.social/@sjs")
      assert_includes(index_text, "=> https://github.com/samsonjs")
      assert_includes(index_text, "=> mailto:sami@samhuri.net")
      refute_includes(markdown_text, "Read on the web")
      assert_includes(html_text, "Read on the web")
      assert_includes(markdown_text, "=> https://example.com")
      assert_includes(html_text, "=> https://example.org")
      assert_includes(markdown_text, "=> /posts Back to posts")
      assert_includes(archive_text, "# samhuri.net posts")
      assert_includes(archive_text, "## Feed")
      assert_match(%r{=> /posts/2025/11/link-post/ 2025-11-07 - Link Post\n=> https://example.net/story}, archive_text)
      assert_includes(archive_text, "=> /posts/2025/11/html-heavy/ 2025-11-06 - HTML Heavy")
      assert_includes(archive_text, "=> /posts/2025/11/markdown-only/ 2025-11-05 - Markdown Only")
      assert_equal(archive_text, feed_text)
    end
  end
end
