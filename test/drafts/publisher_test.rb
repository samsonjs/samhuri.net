require "test_helper"
require "fileutils"
require "tmpdir"
require "pressa/drafts/publisher"
require "pressa/posts/metadata"

class Pressa::Drafts::PublisherTest < Minitest::Test
  def setup
    @root = Dir.mktmpdir
    @drafts_dir = File.join(@root, "public/drafts")
    @posts_dir = File.join(@root, "posts")
    FileUtils.mkdir_p(@drafts_dir)
    @now = Time.new(2026, 6, 7, 14, 30, 0, "-07:00")
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def publisher = Pressa::Drafts::Publisher.new(drafts_dir: @drafts_dir, posts_dir: @posts_dir)

  def write_draft(slug = "tree-well-protocol", **overrides)
    fields = {
      "Author" => "Jane Doe", "Title" => "Tree Well Protocol",
      "Date" => "unpublished", "Timestamp" => "2026-06-01T09:00:00-07:00", "Tags" => "snowboarding"
    }.merge(overrides)
    front = fields.compact.map { |key, value| "#{key}: #{value}" }.join("\n")
    path = File.join(@drafts_dir, "#{slug}.md")
    File.write(path, "---\n#{front}\n---\n\nNever ride alone in deep snow.\n")
    path
  end

  def test_publishes_the_draft_into_posts_by_year_and_month
    write_draft
    result = publisher.publish("tree-well-protocol.md", now: @now)

    assert_equal(File.join(@posts_dir, "2026/06/tree-well-protocol.md"), result.target_path)
    assert(File.exist?(result.target_path))
  end

  def test_stamps_the_publication_date_and_timestamp
    write_draft
    result = publisher.publish("tree-well-protocol.md", now: @now)
    metadata = Pressa::Posts::PostMetadata.parse(File.read(result.target_path))

    assert_equal("7th June, 2026", metadata.formatted_date)
    assert_equal("2026-06-07T14:30:00-07:00", metadata.date.strftime("%Y-%m-%dT%H:%M:%S%:z"))
  end

  def test_keeps_the_rest_of_the_draft_intact
    write_draft
    result = publisher.publish("tree-well-protocol.md", now: @now)
    published = File.read(result.target_path)

    assert_includes(published, "Never ride alone in deep snow.")
    assert_includes(published, "Title: Tree Well Protocol")
    assert_includes(published, "Tags: snowboarding")
  end

  def test_removes_the_draft_once_published
    draft_path = write_draft
    result = publisher.publish("tree-well-protocol.md", now: @now)

    refute(File.exist?(draft_path))
    assert_equal(draft_path, result.draft_path)
  end

  def test_accepts_a_full_path_as_well_as_a_bare_filename
    write_draft
    result = publisher.publish(File.join(@drafts_dir, "tree-well-protocol.md"), now: @now)

    assert(File.exist?(result.target_path))
  end

  def test_refuses_a_path_that_is_already_published
    error = assert_raises(Pressa::Drafts::Publisher::Error) do
      publisher.publish("posts/2026/06/tree-well-protocol.md", now: @now)
    end

    assert_match(/already published/, error.message)
  end

  def test_refuses_a_draft_that_is_not_there
    assert_raises(Pressa::Drafts::Publisher::NotFound) { publisher.publish("nope.md", now: @now) }
  end

  # bin/publish-draft commits and pushes before the build runs, so a draft that
  # can't become a valid post has to fail here rather than at build time.
  def test_refuses_a_draft_with_no_date_line
    draft_path = write_draft("no-date", "Date" => nil)

    error = assert_raises(Pressa::Drafts::Publisher::Invalid) { publisher.publish("no-date.md", now: @now) }

    assert_match(/Date/, error.message)
    assert(File.exist?(draft_path), "the draft should be left alone")
  end

  def test_refuses_a_draft_with_no_timestamp_line
    write_draft("no-timestamp", "Timestamp" => nil)

    error = assert_raises(Pressa::Drafts::Publisher::Invalid) { publisher.publish("no-timestamp.md", now: @now) }

    assert_match(/Timestamp/, error.message)
  end

  def test_refuses_a_draft_with_no_front_matter
    File.write(File.join(@drafts_dir, "bare.md"), "Just some notes.\n")

    assert_raises(Pressa::Drafts::Publisher::Invalid) { publisher.publish("bare.md", now: @now) }
  end

  def test_refuses_to_overwrite_an_existing_post
    write_draft
    existing = File.join(@posts_dir, "2026/06/tree-well-protocol.md")
    FileUtils.mkdir_p(File.dirname(existing))
    File.write(existing, "the original post\n")

    error = assert_raises(Pressa::Drafts::Publisher::Conflict) { publisher.publish("tree-well-protocol.md", now: @now) }

    assert_match(%r{posts/2026/06/tree-well-protocol\.md}, error.message)
    assert_equal("the original post\n", File.read(existing))
    assert(File.exist?(File.join(@drafts_dir, "tree-well-protocol.md")), "the draft should be left alone")
  end
end
