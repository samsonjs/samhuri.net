require "phlex"
require "pressa/views/post_list_item_view"

module Pressa
  module Views
    class TagPostsView < Phlex::HTML
      def initialize(tag:, posts:, site:)
        @tag = tag
        @posts = posts
        @site = site
      end

      def view_template
        div(class: "container") do
          h1 { "Tag: #{@tag}" }

          ul(class: "posts") do
            @posts.each do |post|
              render PostListItemView.new(post:)
            end
          end
        end
      end
    end
  end
end
