require "test_helper"
require "tmpdir"

class Pressa::Posts::RSSFeedWriterTest < Minitest::Test
  class PostsByYearStub
    attr_accessor :posts

    def initialize(posts)
      @posts = posts
    end

    def recent_posts(_limit = 30)
      @posts
    end
  end

  def setup
    @site = Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net"
    )
    @posts_by_year = PostsByYearStub.new([link_post])
    @writer = Pressa::Posts::RSSFeedWriter.new(site: @site, posts_by_year: @posts_by_year)
  end

  def test_write_feed_for_link_post_uses_arrow_title_permalink_and_content
    Dir.mktmpdir do |dir|
      @writer.write_feed(target_path: dir, limit: 30)
      xml = File.read(File.join(dir, "feed.xml"))

      assert_includes(xml, "<title>→ GitHub Flow Like a Pro</title>")
      assert_includes(xml, "<guid isPermaLink=\"true\">https://samhuri.net/posts/2015/05/github-flow-like-a-pro</guid>")
      assert_includes(xml, "https://samhuri.net/feed.xml")
      assert_includes(xml, "<author>Sami Samhuri</author>")
      assert_match(%r{<content:encoded>\s*<!\[CDATA\[}m, xml)
    end
  end

  def test_write_feed_for_regular_post_uses_plain_title
    @posts_by_year.posts = [regular_post]

    Dir.mktmpdir do |dir|
      @writer.write_feed(target_path: dir, limit: 30)
      xml = File.read(File.join(dir, "feed.xml"))

      assert_includes(xml, "<title>Swift Optional OR</title>")
      refute_includes(xml, "→ Swift Optional OR")
    end
  end

  def test_write_feed_without_posts_skips_channel_pub_date
    @posts_by_year.posts = []

    Dir.mktmpdir do |dir|
      @writer.write_feed(target_path: dir, limit: 30)
      xml = File.read(File.join(dir, "feed.xml"))

      assert_includes(xml, "<channel>")
      refute_match(%r{<channel>.*?<pubDate>.*?</pubDate>}m, xml)
    end
  end

  private

  def link_post
    Pressa::Posts::Post.new(
      slug: "github-flow-like-a-pro",
      title: "GitHub Flow Like a Pro",
      author: "Sami Samhuri",
      date: DateTime.parse("2015-05-28T07:42:27-07:00"),
      formatted_date: "28th May, 2015",
      link: "http://haacked.com/archive/2014/07/28/github-flow-aliases/",
      body: "<p>hello</p>",
      excerpt: "hello...",
      path: "/posts/2015/05/github-flow-like-a-pro"
    )
  end

  def regular_post
    Pressa::Posts::Post.new(
      slug: "swift-optional-or",
      title: "Swift Optional OR",
      author: "Sami Samhuri",
      date: DateTime.parse("2017-10-01T10:00:00-07:00"),
      formatted_date: "1st October, 2017",
      body: "<p>hello</p>",
      excerpt: "hello...",
      path: "/posts/2017/10/swift-optional-or"
    )
  end
end
