require "test_helper"

class Pressa::Views::LayoutTest < Minitest::Test
  def content_view
    Class.new(Phlex::HTML) do
      def view_template
        article do
          h1 { "Hello" }
        end
      end
    end.new
  end

  def site
    @site ||= Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net"
    )
  end

  def site_with_copyright_start_year(year)
    Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net",
      copyright_start_year: year
    )
  end

  def site_with_remote_links(links)
    Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net",
      output_options: Pressa::HTMLOutputOptions.new(remote_links: links)
    )
  end

  def test_rendering_child_components_as_html_instead_of_escaped_text
    html = Pressa::Views::Layout.new(
      site:,
      canonical_url: "https://samhuri.net/posts/",
      content: content_view
    ).call

    assert_includes(html, "<article>")
    assert_includes(html, "<h1>Hello</h1>")
    refute_includes(html, "&lt;article&gt;")
  end

  def test_keeps_escaping_enabled_for_untrusted_string_fields
    subtitle = "<img src=x onerror=alert(1)>"
    html = Pressa::Views::Layout.new(
      site:,
      canonical_url: "https://samhuri.net/posts/",
      page_subtitle: subtitle,
      content: content_view
    ).call

    assert_includes(html, "<title>samhuri.net: &lt;img src=x onerror=alert(1)&gt;</title>")
  end

  def test_preserves_absolute_stylesheet_urls
    cdn_site = Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net",
      styles: [Pressa::Stylesheet.new(href: "https://cdn.example.com/site.css")]
    )

    html = Pressa::Views::Layout.new(
      site: cdn_site,
      canonical_url: "https://samhuri.net/posts/",
      content: content_view
    ).call

    assert_includes(html, %(<link rel="stylesheet" type="text/css" href="https://cdn.example.com/site.css">))
  end

  def test_footer_renders_year_range_using_copyright_start_year
    html = Pressa::Views::Layout.new(
      site: site_with_copyright_start_year(2006),
      canonical_url: "https://samhuri.net/posts/",
      content: content_view
    ).call

    assert_includes(html, "<footer>© 2006 - #{Time.now.year} <a href=\"https://samhuri.net/about\">Sami Samhuri</a></footer>")
  end

  def test_footer_renders_single_year_when_start_year_matches_current_year
    current_year = Time.now.year
    html = Pressa::Views::Layout.new(
      site: site_with_copyright_start_year(current_year),
      canonical_url: "https://samhuri.net/posts/",
      content: content_view
    ).call

    assert_includes(html, "<footer>© #{current_year} <a href=\"https://samhuri.net/about\">Sami Samhuri</a></footer>")
    refute_includes(html, "<footer>© #{current_year} - #{current_year} ")
  end

  def test_remote_links_render_from_output_config
    html = Pressa::Views::Layout.new(
      site: site_with_remote_links([
        Pressa::OutputLink.new(label: "Mastodon", href: "https://techhub.social/@sjs", icon: "mastodon"),
        Pressa::OutputLink.new(label: "Gemini", href: "gemini://samhuri.net", icon: "gemini"),
        Pressa::OutputLink.new(label: "GitHub", href: "https://github.com/samsonjs", icon: "github"),
        Pressa::OutputLink.new(label: "RSS", href: "/feed.xml", icon: "rss")
      ]),
      canonical_url: "https://samhuri.net/posts/",
      content: content_view
    ).call

    assert_includes(html, "href=\"https://techhub.social/@sjs\"")
    assert_includes(html, "href=\"gemini://samhuri.net\"")
    assert_includes(html, "href=\"https://github.com/samsonjs\"")
    assert_includes(html, "href=\"https://samhuri.net/feed.xml\"")
    assert_includes(html, "aria-label=\"Mastodon\"")
    assert_includes(html, "aria-label=\"Gemini\"")
    assert_includes(html, "aria-label=\"GitHub\"")
    assert_includes(html, "aria-label=\"RSS\"")
  end

  def test_missing_remote_links_do_not_render_hardcoded_profiles
    html = Pressa::Views::Layout.new(
      site:,
      canonical_url: "https://samhuri.net/posts/",
      content: content_view
    ).call

    refute_includes(html, "techhub.social")
    refute_includes(html, "github.com/samsonjs")
  end
end
