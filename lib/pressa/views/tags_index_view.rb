require "phlex"

module Pressa
  module Views
    class TagsIndexView < Phlex::HTML
      def initialize(tag_index:, site:)
        @tag_index = tag_index
        @site = site
      end

      def view_template
        div(class: "container") do
          h1 { "Tags" }

          ul(class: "tags") do
            @tag_index.counts.each do |tag, count|
              li do
                a(href: tag_path(tag)) { tag }
                plain " (#{count})"
              end
            end
          end
        end
      end

      private

      def tag_path(tag)
        @site.url_for("/tags/#{@tag_index.slug(tag)}/")
      end
    end
  end
end
