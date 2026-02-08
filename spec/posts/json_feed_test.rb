require "test_helper"
require "json"
require "tmpdir"

class Pressa::Posts::JSONFeedWriterTest < Minitest::Test
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
      url: "https://samhuri.net",
      image_url: "https://samhuri.net/images/me.jpg"
    )

    @posts_by_year = PostsByYearStub.new([link_post])
    @writer = Pressa::Posts::JSONFeedWriter.new(site: @site, posts_by_year: @posts_by_year)
  end

  def test_write_feed_for_link_posts_uses_permalink_as_url_and_keeps_external_url
    Dir.mktmpdir do |dir|
      @writer.write_feed(target_path: dir, limit: 30)
      feed = JSON.parse(File.read(File.join(dir, "feed.json")))
      item = feed.fetch("items").first

      assert_equal("https://samhuri.net/posts/2015/05/github-flow-like-a-pro", item.fetch("id"))
      assert_equal("https://samhuri.net/posts/2015/05/github-flow-like-a-pro", item.fetch("url"))
      assert_equal("http://haacked.com/archive/2014/07/28/github-flow-aliases/", item.fetch("external_url"))
    end
  end

  def test_write_feed_for_regular_posts_omits_external_url
    @posts_by_year.posts = [regular_post]

    Dir.mktmpdir do |dir|
      @writer.write_feed(target_path: dir, limit: 30)
      feed = JSON.parse(File.read(File.join(dir, "feed.json")))
      item = feed.fetch("items").first

      assert_equal("https://samhuri.net/posts/2017/10/swift-optional-or", item.fetch("url"))
      refute(item.key?("external_url"))
    end
  end

  def test_write_feed_expands_root_relative_links_in_content_html
    @posts_by_year.posts = [post_with_assets]

    Dir.mktmpdir do |dir|
      @writer.write_feed(target_path: dir, limit: 30)
      feed = JSON.parse(File.read(File.join(dir, "feed.json")))
      item = feed.fetch("items").first
      content_html = item.fetch("content_html")

      assert_includes(content_html, 'href="https://samhuri.net/posts/2010/01/basics-of-the-mach-o-file-format"')
      assert_includes(content_html, 'src="https://samhuri.net/images/me.jpg"')
      assert_includes(content_html, 'href="//cdn.example.net/app.js"')
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

  def post_with_assets
    Pressa::Posts::Post.new(
      slug: "swift-optional-or",
      title: "Swift Optional OR",
      author: "Sami Samhuri",
      date: DateTime.parse("2017-10-01T10:00:00-07:00"),
      formatted_date: "1st October, 2017",
      body: '<p><a href="/posts/2010/01/basics-of-the-mach-o-file-format">read</a></p>' \
            '<p><img src="/images/me.jpg" alt="me"></p>' \
            '<p><a href="//cdn.example.net/app.js">cdn</a></p>',
      excerpt: "hello...",
      path: "/posts/2017/10/swift-optional-or"
    )
  end
end
