require 'phlex'

module Pressa
  module Views
    class ArchiveView < Phlex::HTML
      def initialize(posts_by_year:, site:)
        @posts_by_year = posts_by_year
        @site = site
      end

      def view_template
        article(class: "archive") do
          h1 { "Archive" }

          @posts_by_year.sorted_years.each do |year|
            year_posts = @posts_by_year.by_year[year]
            render_year(year, year_posts)
          end
        end
      end

      private

      def render_year(year, year_posts)
        section(class: "year") do
          h2 do
            a(href: @site.url_for("/posts/#{year}/")) { year.to_s }
          end

          year_posts.sorted_months.each do |month_posts|
            render_month(year, month_posts)
          end
        end
      end

      def render_month(year, month_posts)
        month = month_posts.month

        section(class: "month") do
          h3 do
            a(href: @site.url_for("/posts/#{year}/#{month.padded}/")) do
              "#{month.name} #{year}"
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
