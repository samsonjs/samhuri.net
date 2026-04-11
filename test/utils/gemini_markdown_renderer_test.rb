require "test_helper"
require "tmpdir"

class Pressa::Utils::GeminiMarkdownRendererTest < Minitest::Test
  def renderer
    @renderer ||= Pressa::Utils::GeminiMarkdownRenderer.new
  end

  def site
    @site ||= Pressa::Site.new(
      author: "Fat Mike",
      email: "mike@nofx.example.net",
      title: "NOFX",
      description: "Punk in Drublic",
      url: "https://nofx.example.net",
      output_format: "gemini"
    )
  end

  def with_rendered_file(filename, content)
    Dir.mktmpdir do |base|
      src = File.join(base, filename)
      FileUtils.mkdir_p(File.dirname(src))
      File.write(src, content)
      out = File.join(base, "out")
      FileUtils.mkdir_p(out)
      renderer.render(site: site, file_path: src, target_dir: out)
      yield out
    end
  end

  def test_can_render_file
    assert renderer.can_render_file?(filename: "post.md", extension: "md")
    refute renderer.can_render_file?(filename: "page.html", extension: "html")
    refute renderer.can_render_file?(filename: "page.gmi", extension: "gmi")
  end

  def test_render_writes_gemtext_with_title_and_web_link
    content = <<~MARKDOWN
      ---
      Title: Punk in Drublic
      ---
      ## The album

      A [classic](https://nofx.example.net/pid) record.
    MARKDOWN

    with_rendered_file("public/pid.md", content) do |out|
      gemtext = File.read(File.join(out, "pid", "index.gmi"))
      assert_includes gemtext, "# Punk in Drublic"
      assert_includes gemtext, "## The album"
      assert_includes gemtext, "=> https://nofx.example.net/pid/"
      assert_includes gemtext, "Read on the web"
    end
  end

  def test_render_nested_path_writes_to_correct_subdirectory
    content = "---\nTitle: Heavy Petting Zoo\n---\nContent"
    with_rendered_file("public/albums/hpz.md", content) do |out|
      assert File.exist?(File.join(out, "albums", "hpz", "index.gmi"))
      gemtext = File.read(File.join(out, "albums", "hpz", "index.gmi"))
      assert_includes gemtext, "=> https://nofx.example.net/albums/hpz/ Read on the web"
    end
  end

  def test_render_show_extension_writes_flat_file
    content = <<~MARKDOWN
      ---
      Title: White Trash Two Heebs and a Bean
      Show extension: true
      ---
      Content
    MARKDOWN

    with_rendered_file("public/wt2hab.md", content) do |out|
      assert File.exist?(File.join(out, "wt2hab.gmi"))
      refute File.exist?(File.join(out, "wt2hab", "index.gmi"))
      gemtext = File.read(File.join(out, "wt2hab.gmi"))
      assert_includes gemtext, "=> https://nofx.example.net/wt2hab.html Read on the web"
    end
  end

  def test_render_falls_back_to_filename_as_title
    with_rendered_file("public/so-long.md", "No frontmatter here.") do |out|
      gemtext = File.read(File.join(out, "so-long", "index.gmi"))
      assert_includes gemtext, "# So-long"
    end
  end
end
