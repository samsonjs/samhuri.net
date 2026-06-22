require "pressa/utils/file_writer"
require "pressa/views/layout"
require "pressa/views/drafts_view"
require "pressa/drafts"

module Pressa
  class Drafts
    class Writer
      def initialize(site:, entries:)
        @site = site
        @entries = entries
      end

      def write_index(target_path:)
        content_view = Views::DraftsView.new(entries: @entries, site: @site)

        layout = Views::Layout.new(
          site: @site,
          page_subtitle: "Drafts",
          canonical_url: @site.url_for("/drafts/"),
          page_description: "Unpublished drafts",
          content: content_view
        )

        file_path = File.join(target_path, "drafts", "index.html")
        Utils::FileWriter.write(path: file_path, content: layout.call)
      end
    end
  end
end
