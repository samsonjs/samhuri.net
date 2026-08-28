require "test_helper"
require "pressa/web/preview"

class Pressa::Web::PreviewTest < Minitest::Test
  def build_site(output_format)
    options =
      if output_format == "gemini"
        Pressa::GeminiOutputOptions.new
      else
        Pressa::HTMLOutputOptions.new
      end

    Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net",
      output_format:,
      output_options: options
    )
  end

  def preview
    @preview ||= Pressa::Web::Preview.new(
      html_site: build_site("html"),
      gemini_site: build_site("gemini")
    )
  end

  def link_post_source
    <<~MARKDOWN
      ---
      Title: Tree Well Protocol
      Author: Jane Doe
      Date: 7th June, 2026
      Timestamp: 2026-06-07T14:30:00-07:00
      Tags: snowboarding, safety
      Link: https://powder.example.net/tree-wells
      ---

      Never ride alone in deep snow.
    MARKDOWN
  end

  def test_renders_html_and_gemtext_for_the_same_source
    result = preview.render(link_post_source, slug: "tree-well-protocol")

    assert_equal("Tree Well Protocol", result.title)
    assert_includes(result.html, "<p>Never ride alone in deep snow.</p>")
    assert_includes(result.html, "Tree Well Protocol")
    assert_includes(result.gemtext, "# Tree Well Protocol")
    assert_includes(result.gemtext, "=> https://powder.example.net/tree-wells")
    assert_includes(result.gemtext, "Never ride alone in deep snow.")
  end

  def test_html_is_a_whole_page_not_a_fragment
    result = preview.render(link_post_source, slug: "tree-well-protocol")

    assert_match(/\A<!DOCTYPE html>/i, result.html)
  end

  def test_gemtext_flags_raw_html_the_capsule_cannot_render
    source = link_post_source.sub(
      "Never ride alone in deep snow.",
      "<p>Never ride alone in <strong>deep</strong> snow.</p>"
    )
    result = preview.render(source, slug: "tree-well-protocol")

    assert_includes(result.gemtext, "Read on the web")
  end

  def test_renders_an_unpublished_draft
    source = <<~MARKDOWN
      ---
      Author: Fat Mike
      Title: Lift Line Notes
      Date: unpublished
      Timestamp: 2026-06-07T14:30:00-07:00
      Tags:
      ---

      Chairlift conversations, collected.
    MARKDOWN

    result = preview.render(source, slug: "lift-line-notes")

    assert_equal("Lift Line Notes", result.title)
    assert_includes(result.gemtext, "unpublished by Fat Mike")
    assert_includes(result.html, "Chairlift conversations, collected.")
  end

  def test_raises_a_preview_error_for_source_without_front_matter
    error = assert_raises(Pressa::Web::Preview::Error) do
      preview.render("Just some notes.\n", slug: "notes")
    end

    assert_match(/front-matter/i, error.message)
  end

  def test_raises_a_preview_error_when_required_fields_are_missing
    source = "---\nTitle: Half a Post\n---\n\nBody.\n"

    error = assert_raises(Pressa::Web::Preview::Error) do
      preview.render(source, slug: "half-a-post")
    end

    assert_match(/Author/, error.message)
  end
end
