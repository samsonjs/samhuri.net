require "test_helper"
require "fileutils"
require "tmpdir"

class Pressa::Utils::MarkdownRendererTest < Minitest::Test
  def renderer
    @renderer ||= Pressa::Utils::MarkdownRenderer.new
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

  def test_can_render_file_checks_md_extension
    assert(renderer.can_render_file?(filename: "about.md", extension: "md"))
    refute(renderer.can_render_file?(filename: "about.txt", extension: "txt"))
  end

  def test_render_writes_pretty_url_output_by_default
    Dir.mktmpdir do |dir|
      source_file = File.join(dir, "public", "about.md")
      target_dir = File.join(dir, "www")
      FileUtils.mkdir_p(File.dirname(source_file))

      File.write(source_file, <<~MARKDOWN)
        ---
        Title: About
        Description: About page
        ---

        This is [my bio](https://example.net).
      MARKDOWN

      renderer.render(site:, file_path: source_file, target_dir:)

      output_file = File.join(target_dir, "about", "index.html")
      assert(File.exist?(output_file))

      html = File.read(output_file)
      assert_includes(html, "<title>samhuri.net: About</title>")
      assert_includes(html, "<meta name=\"description\" content=\"About page\">")
      assert_includes(html, "<meta property=\"og:type\" content=\"website\">")
    end
  end

  def test_render_writes_html_extension_when_enabled_and_uses_fallbacks
    Dir.mktmpdir do |dir|
      source_file = File.join(dir, "public", "docs", "readme.md")
      target_dir = File.join(dir, "www", "docs")
      FileUtils.mkdir_p(File.dirname(source_file))

      File.write(source_file, <<~MARKDOWN)
        ---
        Show extension: yes
        Page type: article
        ---

        Hello <strong>world</strong>. This is an ![img](x.png) excerpt with [a link](https://example.net).
      MARKDOWN

      renderer.render(site:, file_path: source_file, target_dir:)

      output_file = File.join(target_dir, "readme.html")
      assert(File.exist?(output_file))

      html = File.read(output_file)
      assert_includes(html, "<title>samhuri.net: Readme</title>")
      assert_includes(html, "<meta property=\"og:type\" content=\"article\">")
      assert_includes(html, "<meta name=\"description\" content=\"Hello world. This is an excerpt with a link....\">")
      assert_includes(html, "<link rel=\"canonical\" href=\"https://samhuri.net/docs/readme.html\">")
    end
  end

  def test_render_without_front_matter_uses_filename_title
    Dir.mktmpdir do |dir|
      source_file = File.join(dir, "public", "notes.md")
      target_dir = File.join(dir, "www")
      FileUtils.mkdir_p(File.dirname(source_file))

      File.write(source_file, "hello from markdown")
      renderer.render(site:, file_path: source_file, target_dir:)

      html = File.read(File.join(target_dir, "notes", "index.html"))
      assert_includes(html, "<title>samhuri.net: Notes</title>")
      assert_includes(html, "<h1>Notes</h1>")
    end
  end
end
