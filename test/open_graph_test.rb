require "test_helper"
require "pressa/open_graph"

class Pressa::OpenGraphTest < Minitest::Test
  def test_extract_returns_og_image_resolved_against_base_url
    html = <<~HTML
      <html><head>
        <meta property="og:image" content="/images/cover.png">
      </head></html>
    HTML

    result = Pressa::OpenGraph.extract(html, base_url: "https://example.net/posts/cool-thing")
    assert_equal("https://example.net/images/cover.png", result.image)
  end

  def test_extract_preserves_absolute_image_urls
    html = %(<meta property="og:image" content="https://cdn.example.net/cover.png">)

    result = Pressa::OpenGraph.extract(html, base_url: "https://example.net/posts/cool-thing")
    assert_equal("https://cdn.example.net/cover.png", result.image)
  end

  def test_extract_falls_back_to_twitter_image
    html = %(<meta name="twitter:image" content="https://cdn.example.net/tw.png">)

    result = Pressa::OpenGraph.extract(html, base_url: "https://example.net/posts/cool-thing")
    assert_equal("https://cdn.example.net/tw.png", result.image)
  end

  def test_extract_returns_nil_when_no_image_meta_present
    html = "<html><head><title>No image here</title></head></html>"

    refute(Pressa::OpenGraph.extract(html, base_url: "https://example.net"))
  end

  def test_extract_handles_single_quoted_attributes
    html = %(<meta property='og:image' content='https://cdn.example.net/single.png'>)

    result = Pressa::OpenGraph.extract(html, base_url: "https://example.net")
    assert_equal("https://cdn.example.net/single.png", result.image)
  end

  def test_fetch_uses_injected_http_get_and_extracts_image
    html = %(<meta property="og:image" content="https://cdn.example.net/x.png">)
    result = Pressa::OpenGraph.fetch("https://example.net/post", http_get: ->(_url) { html })

    assert_equal("https://cdn.example.net/x.png", result.image)
  end

  def test_fetch_returns_nil_when_http_get_returns_nil
    result = Pressa::OpenGraph.fetch("https://example.net/post", http_get: ->(_url) {})
    assert_nil(result)
  end

  def test_fetch_returns_nil_instead_of_raising_on_network_errors
    failing_get = ->(_url) { raise Net::OpenTimeout, "timed out" }
    result = Pressa::OpenGraph.fetch("https://example.net/post", http_get: failing_get)

    assert_nil(result)
  end
end
