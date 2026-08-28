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

  def test_extract_leaves_image_nil_when_no_image_meta_present
    html = "<html><head><title>No image here</title></head></html>"

    assert_nil(Pressa::OpenGraph.extract(html, base_url: "https://example.net").image)
  end

  def test_extract_handles_single_quoted_attributes
    html = %(<meta property='og:image' content='https://cdn.example.net/single.png'>)

    result = Pressa::OpenGraph.extract(html, base_url: "https://example.net")
    assert_equal("https://cdn.example.net/single.png", result.image)
  end

  def test_extract_returns_og_title
    html = %(<meta property="og:title" content="Ride the Lightning Rail"><title>ignored</title>)

    result = Pressa::OpenGraph.extract(html, base_url: "https://trails.example.net")
    assert_equal("Ride the Lightning Rail", result.title)
  end

  def test_extract_falls_back_to_the_title_element
    html = "<html><head><title>  Powder Day Protocol  </title></head></html>"

    result = Pressa::OpenGraph.extract(html, base_url: "https://powder.example.net")
    assert_equal("Powder Day Protocol", result.title)
  end

  def test_extract_returns_og_description
    html = %(<meta property="og:description" content="A field guide to tree wells.">)

    result = Pressa::OpenGraph.extract(html, base_url: "https://powder.example.net")
    assert_equal("A field guide to tree wells.", result.description)
  end

  def test_extract_falls_back_to_the_meta_description
    html = %(<meta name="description" content="Notes from the lift line.">)

    result = Pressa::OpenGraph.extract(html, base_url: "https://powder.example.net")
    assert_equal("Notes from the lift line.", result.description)
  end

  def test_extract_unescapes_html_entities_in_text_fields
    html = %(<meta property="og:title" content="Bikes &amp; Boards">) +
      %(<meta property="og:description" content="Trent&#39;s workshop">)

    result = Pressa::OpenGraph.extract(html, base_url: "https://beats.example.net")
    assert_equal("Bikes & Boards", result.title)
    assert_equal("Trent's workshop", result.description)
  end

  def test_extract_returns_nil_when_the_page_offers_nothing
    refute(Pressa::OpenGraph.extract("<html><body>hi</body></html>", base_url: "https://example.net"))
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
