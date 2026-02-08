require_relative "../utils/file_writer"
require_relative "../views/layout"
require_relative "../views/post_view"
require_relative "../views/recent_posts_view"
require_relative "../views/archive_view"
require_relative "../views/year_posts_view"
require_relative "../views/month_posts_view"

module Pressa
  module Posts
    class PostWriter
      def initialize(site:, posts_by_year:)
        @site = site
        @posts_by_year = posts_by_year
      end

      def write_posts(target_path:)
        @posts_by_year.all_posts.each do |post|
          write_post(post:, target_path:)
        end
      end

      def write_recent_posts(target_path:, limit: 10)
        recent = @posts_by_year.recent_posts(limit)
        content_view = Views::RecentPostsView.new(posts: recent, site: @site)

        html = render_layout(
          page_subtitle: nil,
          canonical_url: @site.url,
          content: content_view,
          page_description: "Recent posts",
          page_type: "article"
        )

        file_path = File.join(target_path, "index.html")
        Utils::FileWriter.write(path: file_path, content: html)
      end

      def write_archive(target_path:)
        content_view = Views::ArchiveView.new(posts_by_year: @posts_by_year, site: @site)

        html = render_layout(
          page_subtitle: "Archive",
          canonical_url: @site.url_for("/posts/"),
          content: content_view,
          page_description: "Archive of all posts"
        )

        file_path = File.join(target_path, "posts", "index.html")
        Utils::FileWriter.write(path: file_path, content: html)
      end

      def write_year_indexes(target_path:)
        @posts_by_year.sorted_years.each do |year|
          year_posts = @posts_by_year.by_year[year]
          write_year_index(year:, year_posts:, target_path:)
        end
      end

      def write_month_rollups(target_path:)
        @posts_by_year.by_year.each do |year, year_posts|
          year_posts.by_month.each do |_month_num, month_posts|
            write_month_rollup(year:, month_posts:, target_path:)
          end
        end
      end

      private

      def write_post(post:, target_path:)
        content_view = Views::PostView.new(post:, site: @site, article_class: "container")

        html = render_layout(
          page_subtitle: post.title,
          canonical_url: @site.url_for(post.path),
          content: content_view,
          page_scripts: post.scripts,
          page_styles: post.styles,
          page_description: post.excerpt,
          page_type: "article"
        )

        file_path = File.join(target_path, post.path.sub(/^\//, ""), "index.html")
        Utils::FileWriter.write(path: file_path, content: html)
      end

      def write_year_index(year:, year_posts:, target_path:)
        content_view = Views::YearPostsView.new(year:, year_posts:, site: @site)

        html = render_layout(
          page_subtitle: year.to_s,
          canonical_url: @site.url_for("/posts/#{year}/"),
          content: content_view,
          page_description: "Archive of all posts from #{year}",
          page_type: "article"
        )

        file_path = File.join(target_path, "posts", year.to_s, "index.html")
        Utils::FileWriter.write(path: file_path, content: html)
      end

      def write_month_rollup(year:, month_posts:, target_path:)
        month = month_posts.month
        content_view = Views::MonthPostsView.new(year:, month_posts:, site: @site)

        title = "#{month.name} #{year}"
        html = render_layout(
          page_subtitle: title,
          canonical_url: @site.url_for("/posts/#{year}/#{month.padded}/"),
          content: content_view,
          page_description: "Archive of all posts from #{title}",
          page_type: "article"
        )

        file_path = File.join(target_path, "posts", year.to_s, month.padded, "index.html")
        Utils::FileWriter.write(path: file_path, content: html)
      end

      def render_layout(
        page_subtitle:,
        canonical_url:,
        content:,
        page_scripts: [],
        page_styles: [],
        page_description: nil,
        page_type: "website"
      )
        layout = Views::Layout.new(
          site: @site,
          page_subtitle:,
          canonical_url:,
          page_scripts:,
          page_styles:,
          page_description:,
          page_type:,
          content:
        )

        layout.call
      end
    end
  end
end
