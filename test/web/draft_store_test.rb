require "test_helper"
require "fileutils"
require "tmpdir"
require "pressa/web/draft_store"

class Pressa::Web::DraftStoreTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @dir = File.join(@tmpdir, "drafts")
    Dir.mkdir(@dir)
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def store = @store ||= Pressa::Web::DraftStore.new(dir: @dir)

  def write_draft(slug, title:, timestamp: "2026-06-07T14:30:00-07:00", body: "TKTK")
    File.write(File.join(@dir, "#{slug}.md"), <<~MARKDOWN)
      ---
      Author: Sami Samhuri
      Title: #{title}
      Date: unpublished
      Timestamp: #{timestamp}
      Tags:
      ---

      #{body}
    MARKDOWN
  end

  def test_list_is_empty_when_there_are_no_drafts
    assert_empty(store.list)
  end

  def test_list_returns_drafts_newest_first
    write_draft("lift-line-notes", title: "Lift Line Notes", timestamp: "2026-06-01T09:00:00-07:00")
    write_draft("tree-wells", title: "Tree Wells", timestamp: "2026-06-07T09:00:00-07:00")

    assert_equal(["Tree Wells", "Lift Line Notes"], store.list.map(&:title))
    assert_equal(["tree-wells", "lift-line-notes"], store.list.map(&:slug))
  end

  def test_read_returns_the_raw_markdown
    write_draft("tree-wells", title: "Tree Wells", body: "Never ride alone.")

    assert_includes(store.read("tree-wells"), "Never ride alone.")
    assert_includes(store.read("tree-wells"), "Title: Tree Wells")
  end

  def test_read_raises_for_an_unknown_draft
    assert_raises(Pressa::Web::DraftStore::NotFound) { store.read("nope") }
  end

  def test_write_replaces_the_contents_of_an_existing_draft
    write_draft("tree-wells", title: "Tree Wells")
    store.write("tree-wells", "---\nTitle: Tree Wells\n---\n\nRewritten.\n",
      expected_version: store.version("tree-wells"))

    assert_includes(store.read("tree-wells"), "Rewritten.")
  end

  def test_write_raises_for_an_unknown_draft
    assert_raises(Pressa::Web::DraftStore::NotFound) do
      store.write("nope", "content", expected_version: "whatever")
    end
  end

  def test_write_normalizes_the_crlf_browsers_send_from_a_textarea
    write_draft("tree-wells", title: "Tree Wells")
    store.write("tree-wells", "line one\r\nline two\r\n", expected_version: store.version("tree-wells"))

    assert_equal("line one\nline two\n", store.read("tree-wells"))
  end

  # --- concurrent edits -----------------------------------------------------

  def test_version_is_stable_for_unchanged_contents
    write_draft("tree-wells", title: "Tree Wells")

    assert_equal(store.version("tree-wells"), store.version("tree-wells"))
  end

  def test_version_changes_once_the_draft_is_written
    write_draft("tree-wells", title: "Tree Wells")
    before = store.version("tree-wells")
    store.write("tree-wells", "something else\n", expected_version: before)

    refute_equal(before, store.version("tree-wells"))
  end

  def test_write_refuses_a_version_that_is_out_of_date
    write_draft("tree-wells", title: "Tree Wells")
    stale = store.version("tree-wells")
    store.write("tree-wells", "the other tab got here first\n", expected_version: stale)

    error = assert_raises(Pressa::Web::DraftStore::Stale) do
      store.write("tree-wells", "my slower edit\n", expected_version: stale)
    end

    assert_equal("the other tab got here first\n", store.read("tree-wells"))
    assert_equal("the other tab got here first\n", error.current_content)
    assert_equal(store.version("tree-wells"), error.current_version)
  end

  def test_write_refuses_a_missing_version
    write_draft("tree-wells", title: "Tree Wells")

    assert_raises(Pressa::Web::DraftStore::Stale) do
      store.write("tree-wells", "no token at all\n", expected_version: nil)
    end

    refute_includes(store.read("tree-wells"), "no token at all")
  end

  def test_rewriting_identical_content_is_not_a_conflict
    write_draft("tree-wells", title: "Tree Wells")
    same = store.read("tree-wells")
    store.write("tree-wells", same, expected_version: store.version("tree-wells"))

    assert_equal(same, store.read("tree-wells"))
  end

  def test_create_writes_a_draft_from_the_title_and_returns_its_slug
    slug = store.create("Tree Well Protocol")

    assert_equal("tree-well-protocol", slug)
    assert_includes(store.read(slug), "Title: Tree Well Protocol")
    assert_includes(store.read(slug), "Date: unpublished")
  end

  def test_create_refuses_to_clobber_an_existing_draft
    store.create("Tree Well Protocol")

    assert_raises(Pressa::Web::DraftStore::Conflict) { store.create("Tree Well Protocol") }
  end

  def test_create_rejects_a_title_with_no_usable_slug
    assert_raises(Pressa::Web::DraftStore::InvalidTitle) { store.create("!!!") }
    assert_raises(Pressa::Web::DraftStore::InvalidTitle) { store.create("   ") }
  end

  def test_delete_removes_the_draft
    store.create("Tree Well Protocol")
    store.delete("tree-well-protocol")

    assert_empty(store.list)
  end

  def test_slugs_that_could_escape_the_drafts_directory_are_refused
    outside = File.expand_path("../secrets.md", @dir)
    File.write(outside, "not yours")

    ["../secrets", "..%2Fsecrets", "sub/dir", "/etc/passwd", "tree wells", ""].each do |slug|
      assert_raises(Pressa::Web::DraftStore::InvalidSlug, "expected #{slug.inspect} to be refused") do
        store.read(slug)
      end
    end
  end
end
