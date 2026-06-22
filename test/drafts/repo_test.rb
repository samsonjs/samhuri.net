require "test_helper"
require "fileutils"
require "tmpdir"

class Pressa::Drafts::RepoTest < Minitest::Test
  def test_read_entries_parses_title_and_timestamp
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "powder-day.md"), <<~MARKDOWN)
        ---
        Author: Shaun White
        Title: Powder Day at Baker
        Date: unpublished
        Timestamp: 2025-11-05T10:00:00-08:00
        Tags:
        ---

        TKTK
      MARKDOWN

      entries = Pressa::Drafts::Repo.new(dir:).read_entries

      assert_equal(1, entries.length)
      entry = entries.first
      assert_equal("powder-day", entry.slug)
      assert_equal("Powder Day at Baker", entry.title)
      assert_equal("/drafts/powder-day/", entry.path)
      assert_equal(2025, entry.timestamp.year)
    end
  end

  def test_read_entries_handles_legacy_unix_timestamps
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "old-draft.md"), <<~MARKDOWN)
        ---
        Author: Greg Graffin
        Title: Old Draft
        Date: unpublished
        Timestamp: 1435424525
        ---

        TKTK
      MARKDOWN

      entry = Pressa::Drafts::Repo.new(dir:).read_entries.first

      assert_equal(2015, entry.timestamp.year)
    end
  end

  def test_read_entries_sorts_newest_first
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "older.md"), <<~MARKDOWN)
        ---
        Author: Fat Mike
        Title: Older Draft
        Date: unpublished
        Timestamp: 2024-01-01T00:00:00-08:00
        ---

        TKTK
      MARKDOWN

      File.write(File.join(dir, "newer.md"), <<~MARKDOWN)
        ---
        Author: El Hefe
        Title: Newer Draft
        Date: unpublished
        Timestamp: 2025-01-01T00:00:00-08:00
        ---

        TKTK
      MARKDOWN

      entries = Pressa::Drafts::Repo.new(dir:).read_entries

      assert_equal(["Newer Draft", "Older Draft"], entries.map(&:title))
    end
  end

  def test_read_entries_skips_files_without_front_matter
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "no-front-matter.md"), "# Just a heading\n")

      entries = Pressa::Drafts::Repo.new(dir:).read_entries

      assert_empty(entries)
    end
  end
end
