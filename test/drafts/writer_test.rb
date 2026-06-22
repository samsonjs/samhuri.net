require "test_helper"
require "tmpdir"

class Pressa::Drafts::WriterTest < Minitest::Test
  def site
    @site ||= Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net"
    )
  end

  def entries
    @entries ||= [
      Pressa::Drafts::Entry.new(
        slug: "powder-day",
        title: "Powder Day at Baker",
        timestamp: DateTime.parse("2025-11-05T10:00:00-08:00"),
        path: "/drafts/powder-day/"
      )
    ]
  end

  def test_write_index_writes_drafts_index_page
    Dir.mktmpdir do |dir|
      Pressa::Drafts::Writer.new(site:, entries:).write_index(target_path: dir)

      index_path = File.join(dir, "drafts", "index.html")
      assert(File.exist?(index_path))
      html = File.read(index_path)
      assert_includes(html, "Drafts")
      assert_includes(html, "Powder Day at Baker")
      assert_includes(html, "/drafts/powder-day/")
    end
  end
end
