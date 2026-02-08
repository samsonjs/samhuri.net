require "test_helper"

class Pressa::Views::RenderingTest < Minitest::Test
  def site
    @site ||= Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net"
    )
  end

  def regular_post
    @regular_post ||= Pressa::Posts::Post.new(
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

  def link_post
    @link_post ||= Pressa::Posts::Post.new(
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

  def test_post_view_renders_regular_post_and_article_class
    html = Pressa::Views::PostView.new(
      post: regular_post,
      site:,
      article_class: "container"
    ).call

    assert_includes(html, "<article class=\"container\">")
    assert_includes(html, "<a href=\"/posts/2017/10/swift-optional-or\">Swift Optional OR</a>")
    assert_includes(html, "<a href=\"/posts/2017/10/swift-optional-or\" class=\"permalink\">∞</a>")
  end

  def test_post_view_renders_link_post_title_with_arrow
    html = Pressa::Views::PostView.new(post: link_post, site:).call

    assert_includes(html, "→ GitHub Flow Like a Pro")
    assert_includes(html, "http://haacked.com/archive/2014/07/28/github-flow-aliases/")
  end

  def test_feed_post_view_expands_root_relative_urls_only
    post = Pressa::Posts::Post.new(
      slug: "with-assets",
      title: "With Assets",
      author: "Sami Samhuri",
      date: DateTime.parse("2017-10-01T10:00:00-07:00"),
      formatted_date: "1st October, 2017",
      body: '<p><a href="/posts/2010/01/basics-of-the-mach-o-file-format">read</a></p>' \
            '<p><img src="/images/me.jpg" alt="me"></p>' \
            '<p><a href="//cdn.example.net/app.js">cdn</a></p>',
      excerpt: "hello...",
      path: "/posts/2017/10/with-assets"
    )

    html = Pressa::Views::FeedPostView.new(post:, site:).call

    assert_includes(html, 'href="https://samhuri.net/posts/2010/01/basics-of-the-mach-o-file-format"')
    assert_includes(html, 'src="https://samhuri.net/images/me.jpg"')
    assert_includes(html, 'href="//cdn.example.net/app.js"')
  end

  def test_project_and_projects_views_render_project_links_and_stats
    project = Pressa::Projects::Project.new(
      name: "demo",
      title: "Demo Project",
      description: "Demo project description",
      url: "https://github.com/samsonjs/demo"
    )

    listing = Pressa::Views::ProjectsView.new(projects: [project], site:).call
    details = Pressa::Views::ProjectView.new(project:, site:).call

    assert_includes(listing, "Demo Project")
    assert_includes(listing, "https://samhuri.net/projects/demo")
    assert_includes(details, "https://github.com/samsonjs/demo/stargazers")
    assert_includes(details, "https://github.com/samsonjs/demo/network/members")
  end

  def test_archive_views_render_year_month_and_both_post_types
    may_posts = Pressa::Posts::MonthPosts.new(
      month: Pressa::Posts::Month.new(name: "May", number: 5, padded: "05"),
      posts: [link_post]
    )
    oct_posts = Pressa::Posts::MonthPosts.new(
      month: Pressa::Posts::Month.new(name: "October", number: 10, padded: "10"),
      posts: [regular_post]
    )

    by_year = {
      2017 => Pressa::Posts::YearPosts.new(year: 2017, by_month: {10 => oct_posts}),
      2015 => Pressa::Posts::YearPosts.new(year: 2015, by_month: {5 => may_posts})
    }
    posts_by_year = Pressa::Posts::PostsByYear.new(by_year:)

    year_html = Pressa::Views::YearPostsView.new(year: 2015, year_posts: by_year[2015], site:).call
    month_html = Pressa::Views::MonthPostsView.new(year: 2017, month_posts: oct_posts, site:).call
    recent_html = Pressa::Views::RecentPostsView.new(posts: [regular_post], site:).call
    archive_html = Pressa::Views::ArchiveView.new(posts_by_year:, site:).call

    assert_includes(year_html, "https://samhuri.net/posts/2015/05/")
    assert_includes(year_html, "→ GitHub Flow Like a Pro")
    assert_match(%r{<a (?=[^>]*class="permalink")(?=[^>]*href="/posts/2015/05/github-flow-like-a-pro")[^>]*>∞</a>}, year_html)

    assert_includes(month_html, "October 2017")
    assert_includes(recent_html, "Swift Optional OR")
    assert_includes(archive_html, "Archive")
    assert_includes(archive_html, "https://samhuri.net/posts/2017/")
    assert_includes(archive_html, "https://samhuri.net/posts/2015/")
  end
end
