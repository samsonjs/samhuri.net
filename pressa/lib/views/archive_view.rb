require 'phlex'
require_relative 'year_posts_view'

module Pressa
  module Views
    class ArchiveView < Phlex::HTML
      def initialize(posts_by_year:, site:)
        @posts_by_year = posts_by_year
        @site = site
      end

      def view_template
        div(class: 'container') do
          h1 { 'Archive' }
        end

        @posts_by_year.sorted_years.each do |year|
          year_posts = @posts_by_year.by_year[year]
          render Views::YearPostsView.new(year:, year_posts:, site: @site)
        end
      end
    end
  end
end
