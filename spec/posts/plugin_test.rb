require "test_helper"
require "fileutils"
require "tmpdir"

class Pressa::Posts::PluginTest < Minitest::Test
  def site
    @site ||= Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net"
    )
  end

  def test_setup_skips_when_posts_directory_does_not_exist
    Dir.mktmpdir do |source_path|
      plugin = Pressa::Posts::Plugin.new
      plugin.setup(site:, source_path:)

      assert_nil(plugin.posts_by_year)
    end
  end

  def test_render_skips_when_setup_did_not_load_posts
    Dir.mktmpdir do |target_path|
      plugin = Pressa::Posts::Plugin.new
      plugin.render(site:, target_path:)

      refute(File.exist?(File.join(target_path, "index.html")))
      refute(File.exist?(File.join(target_path, "feed.json")))
      refute(File.exist?(File.join(target_path, "feed.xml")))
    end
  end

  def test_setup_and_render_write_post_indexes_and_feeds
    Dir.mktmpdir do |root|
      source_path = File.join(root, "source")
      target_path = File.join(root, "target")
      posts_dir = File.join(source_path, "posts", "2025", "11")
      FileUtils.mkdir_p(posts_dir)

      File.write(File.join(posts_dir, "shredding.md"), <<~MARKDOWN)
        ---
        Title: Shredding in November
        Author: Shaun White
        Date: 5th November, 2025
        Timestamp: 2025-11-05T10:00:00-08:00
        ---

        Had an epic day at Whistler. The powder was deep and the lines were short.
      MARKDOWN

      plugin = Pressa::Posts::Plugin.new
      plugin.setup(site:, source_path:)
      plugin.render(site:, target_path:)

      assert(File.exist?(File.join(target_path, "index.html")))
      assert(File.exist?(File.join(target_path, "posts/index.html")))
      assert(File.exist?(File.join(target_path, "posts/2025/index.html")))
      assert(File.exist?(File.join(target_path, "posts/2025/11/index.html")))
      assert(File.exist?(File.join(target_path, "posts/2025/11/shredding/index.html")))
      assert(File.exist?(File.join(target_path, "feed.json")))
      assert(File.exist?(File.join(target_path, "feed.xml")))
    end
  end
end
