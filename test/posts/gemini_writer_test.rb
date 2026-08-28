require "test_helper"
require "tmpdir"
require "pressa/posts/gemini_writer"
require "pressa/posts/repo"

class Pressa::Posts::GeminiWriterTest < Minitest::Test
  def site
    @site ||= Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net",
      output_format: "gemini",
      output_options: Pressa::GeminiOutputOptions.new
    )
  end

  def post(content)
    Pressa::Posts::PostRepo.new.build_post(content:, slug: "tree-well-protocol")
  end

  def link_post_source
    <<~MARKDOWN
      ---
      Title: Tree Well Protocol
      Author: Jane Doe
      Date: 7th June, 2026
      Timestamp: 2026-06-07T14:30:00-07:00
      Link: https://powder.example.net/tree-wells
      ---

      Never ride alone in deep snow.
    MARKDOWN
  end

  def writer(posts)
    by_month = Pressa::Posts::MonthPosts.new(
      month: Pressa::Posts::Month.new(name: "June", number: 6, padded: "06"),
      posts:
    )
    posts_by_year = Pressa::Posts::PostsByYear.new(
      by_year: {2026 => Pressa::Posts::YearPosts.new(year: 2026, by_month: {6 => by_month})}
    )
    Pressa::Posts::GeminiWriter.new(site:, posts_by_year:)
  end

  def test_post_content_renders_a_single_post_as_gemtext
    entry = post(link_post_source)
    gemtext = writer([entry]).post_content(post: entry)

    assert_includes(gemtext, "# Tree Well Protocol")
    assert_includes(gemtext, "7th June, 2026 by Jane Doe")
    assert_includes(gemtext, "=> https://powder.example.net/tree-wells")
    assert_includes(gemtext, "Never ride alone in deep snow.")
    assert_includes(gemtext, "=> /posts Back to posts")
  end

  def test_post_content_matches_what_write_posts_puts_on_disk
    Dir.mktmpdir do |tmpdir|
      entry = post(link_post_source)
      gemini_writer = writer([entry])
      gemini_writer.write_posts(target_path: tmpdir)
      on_disk = File.read(File.join(tmpdir, "posts/2026/06/tree-well-protocol/index.gmi"))

      assert_equal(on_disk, gemini_writer.post_content(post: entry))
    end
  end
end
