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
end
