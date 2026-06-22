require "phlex"
require "pressa/views/post_list_item_view"

module Pressa
  module Views
    class YearPostsView < Phlex::HTML
      def initialize(year:, year_posts:, site:)
        @year = year
        @year_posts = year_posts
        @site = site
      end

      def view_template
        div(class: "container") do
          h2(class: "year") do
            a(href: year_path) { @year.to_s }
          end

          @year_posts.sorted_months.each do |month_posts|
            render_month(month_posts)
          end
        end
      end

      private

      def year_path
        @site.url_for("/posts/#{@year}/")
      end

      def render_month(month_posts)
        month = month_posts.month

        h3(class: "month") do
          a(href: @site.url_for("/posts/#{@year}/#{month.padded}/")) do
            month.name
          end
        end

        ul(class: "posts") do
          month_posts.sorted_posts.each do |post|
            render PostListItemView.new(post:)
          end
        end
      end
    end
  end
end
