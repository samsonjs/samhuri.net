require 'phlex'
require_relative 'post_view'

module Pressa
  module Views
    class MonthPostsView < Phlex::HTML
      def initialize(year:, month_posts:, site:)
        @year = year
        @month_posts = month_posts
        @site = site
      end

      def view_template
        article(class: "month-posts") do
          h1 { "#{@month_posts.month.name} #{@year}" }

          @month_posts.sorted_posts.each do |post|
            render PostView.new(post:, site: @site)
          end
        end
      end
    end
  end
end
