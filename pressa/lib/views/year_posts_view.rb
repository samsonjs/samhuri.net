require 'phlex'

module Pressa
  module Views
    class YearPostsView < Phlex::HTML
      def initialize(year:, year_posts:, site:)
        @year = year
        @year_posts = year_posts
        @site = site
      end

      def view_template
        article(class: "year-posts") do
          h1 { @year.to_s }

          @year_posts.sorted_months.each do |month_posts|
            render_month(month_posts)
          end
        end
      end

      private

      def render_month(month_posts)
        month = month_posts.month

        section(class: "month") do
          h2 do
            a(href: @site.url_for("/posts/#{@year}/#{month.padded}/")) do
              month.name
            end
          end

          ul do
            month_posts.sorted_posts.each do |post|
              li do
                if post.link_post?
                  a(href: post.link) { "→ #{post.title}" }
                else
                  a(href: @site.url_for(post.path)) { post.title }
                end
                plain " – #{post.formatted_date}"
              end
            end
          end
        end
      end
    end
  end
end
