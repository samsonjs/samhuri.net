require 'phlex'
require_relative 'post_view'

module Pressa
  module Views
    class RecentPostsView < Phlex::HTML
      def initialize(posts:, site:)
        @posts = posts
        @site = site
      end

      def view_template
        div(class: "recent-posts") do
          @posts.each do |post|
            render PostView.new(post:, site: @site)
          end
        end
      end
    end
  end
end
