require "test_helper"

class Pressa::Views::LayoutTest < Minitest::Test
  def test_content_view
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

  def test_rendering_child_components_as_html_instead_of_escaped_text
    html = Pressa::Views::Layout.new(
      site:,
      canonical_url: "https://samhuri.net/posts/",
      content: test_content_view
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
      content: test_content_view
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
      content: test_content_view
    ).call

    assert_includes(html, %(<link rel="stylesheet" type="text/css" href="https://cdn.example.com/site.css">))
  end
end
