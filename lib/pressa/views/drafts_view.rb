require "phlex"

module Pressa
  module Views
    class DraftsView < Phlex::HTML
      def initialize(entries:, site:)
        @entries = entries
        @site = site
      end

      def view_template
        div(class: "container") do
          h1 { "Drafts" }

          ul(class: "posts") do
            @entries.each do |entry|
              render_entry(entry)
            end
          end
        end
      end

      private

      def render_entry(entry)
        li do
          a(href: entry.path) { entry.title }
          time { short_date(entry.timestamp) }
        end
      end

      def short_date(timestamp)
        timestamp.strftime("%-d %b %Y")
      end
    end
  end
end
