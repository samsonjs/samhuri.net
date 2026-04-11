require "test_helper"

class Pressa::Utils::GemtextRendererTest < Minitest::Test
  def test_render_resolves_reference_style_links
    markdown = <<~MARKDOWN
      I'm in [Victoria, BC][vic] and on [GitHub][].

      [vic]: https://example.com/victoria
      [github]: https://github.com/samsonjs
    MARKDOWN

    rendered = Pressa::Utils::GemtextRenderer.render(markdown)

    assert_includes(rendered, "I'm in Victoria, BC and on GitHub.")
    assert_includes(rendered, "=> https://example.com/victoria")
    assert_includes(rendered, "=> https://github.com/samsonjs")
    refute_includes(rendered, "[vic]")
    refute_includes(rendered, "[GitHub][]")
  end

  def test_render_keeps_unresolved_reference_link_text
    markdown = "Read [this][missing] please."
    rendered = Pressa::Utils::GemtextRenderer.render(markdown)

    assert_includes(rendered, "Read [this][missing] please.")
    refute_includes(rendered, "=> ")
  end

  def test_render_collapses_link_only_list_items_to_links
    markdown = <<~MARKDOWN
      ## Where you can find me

      - GitHub: [samsonjs][gh]
      - [Stack Overflow][so]
      - Mastodon: [@sjs@techhub.social][mastodon]
      - Email: [sami@samhuri.net][email]

      [gh]: https://github.com/samsonjs
      [so]: https://stackoverflow.com/users/188752/sami-samhuri
      [mastodon]: https://techhub.social/@sjs
      [email]: mailto:sami@samhuri.net
    MARKDOWN

    rendered = Pressa::Utils::GemtextRenderer.render(markdown)

    assert_includes(rendered, "=> https://github.com/samsonjs")
    assert_includes(rendered, "=> https://stackoverflow.com/users/188752/sami-samhuri")
    assert_includes(rendered, "=> https://techhub.social/@sjs")
    assert_includes(rendered, "=> mailto:sami@samhuri.net")
    refute_includes(rendered, "* GitHub: samsonjs")
    refute_includes(rendered, "* Stack Overflow")
  end

  def test_render_decodes_common_named_html_entities
    markdown = "a &rarr; b &hellip; and down &darr;"
    rendered = Pressa::Utils::GemtextRenderer.render(markdown)

    assert_includes(rendered, "a \u2192 b ... and down \u2193")
    refute_includes(rendered, "&rarr;")
    refute_includes(rendered, "&darr;")
  end

  def test_render_collapses_link_only_text_lines_to_links
    markdown = <<~MARKDOWN
      <a href="/f/volume.rb">&darr; Download volume.rb</a>
    MARKDOWN

    rendered = Pressa::Utils::GemtextRenderer.render(markdown)

    assert_equal("=> /f/volume.rb", rendered)
  end

  def test_render_converts_various_markdown_features
    markdown = <<~MARKDOWN
      ## My [Website](https://powder.example.net "Powder Day")

      >No-space quote with a [link](https://shred.example.net)
      > Normal quote line

      ```ruby
      [link](url) and **bold** preserved
      <script>alert('drop-in')</script>
      ```

      Normal text after fence. **bold** *italic* __under__ _em_ `code` <em>html</em>

      Entities: &uarr; &larr; &nbsp; &foobar;

      <img src="/rails.jpg" alt="rails">

      - Check [this](https://one.example.net) and [that](https://two.example.net) out
      * Star item
      + Plus item

      [my   ref]: <https://ref.example.net>

      See [my ref][].
    MARKDOWN

    rendered = Pressa::Utils::GemtextRenderer.render(markdown)

    assert_includes(rendered, "## My Website")
    assert_includes(rendered, "=> https://powder.example.net")
    assert_includes(rendered, "> No-space quote with a link")
    assert_includes(rendered, "=> https://shred.example.net")
    assert_includes(rendered, "> Normal quote line")
    assert_includes(rendered, "```")
    assert_includes(rendered, "[link](url) and **bold** preserved")
    assert_includes(rendered, "<script>alert('drop-in')</script>")
    assert_includes(rendered, "bold italic under em code html")
    assert_includes(rendered, "\u2191")
    assert_includes(rendered, "\u2190")
    assert_includes(rendered, "&foobar;")
    assert_includes(rendered, "=> /rails.jpg")
    assert_includes(rendered, "* Check this and that out")
    assert_includes(rendered, "=> https://one.example.net")
    assert_includes(rendered, "=> https://two.example.net")
    assert_includes(rendered, "* Star item")
    assert_includes(rendered, "* Plus item")
    assert_includes(rendered, "=> https://ref.example.net")
  end

  def test_render_handles_edge_cases
    assert_equal("", Pressa::Utils::GemtextRenderer.render(""))
    assert_equal("", Pressa::Utils::GemtextRenderer.render(nil))

    rendered = Pressa::Utils::GemtextRenderer.render("Line 1\r\nLine 2\r\n")
    assert_includes(rendered, "Line 1")
    assert_includes(rendered, "Line 2")

    rendered = Pressa::Utils::GemtextRenderer.render("Line 1\n\n\n\nLine 2")
    lines = rendered.split("\n")
    refute lines.each_cons(2).any? { it[0].strip.empty? && it[1].strip.empty? }
  end
end
