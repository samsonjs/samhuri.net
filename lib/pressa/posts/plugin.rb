require "pressa/plugin"
require "pressa/posts/repo"
require "pressa/posts/writer"
require "pressa/posts/gemini_writer"
require "pressa/posts/json_feed"
require "pressa/posts/rss_feed"

module Pressa
  module Posts
    class BasePlugin < Pressa::Plugin
      attr_reader :posts_by_year

      def setup(site:, source_path:)
        posts_dir = File.join(source_path, "posts")
        return unless Dir.exist?(posts_dir)

        repo = PostRepo.new
        @posts_by_year = repo.read_posts(posts_dir)
      end
    end

    class HTMLPlugin < BasePlugin
      def render(site:, target_path:)
        return unless @posts_by_year

        writer = PostWriter.new(site:, posts_by_year: @posts_by_year)
        writer.write_posts(target_path:)
        writer.write_recent_posts(target_path:, limit: 10)
        writer.write_archive(target_path:)
        writer.write_year_indexes(target_path:)
        writer.write_month_rollups(target_path:)

        json_feed = JSONFeedWriter.new(site:, posts_by_year: @posts_by_year)
        json_feed.write_feed(target_path:, limit: 30)

        rss_feed = RSSFeedWriter.new(site:, posts_by_year: @posts_by_year)
        rss_feed.write_feed(target_path:, limit: 30)
      end
    end

    class GeminiPlugin < BasePlugin
      def render(site:, target_path:)
        return unless @posts_by_year

        writer = GeminiWriter.new(site:, posts_by_year: @posts_by_year)
        writer.write_posts(target_path:)
        writer.write_recent_posts(target_path:, limit: gemini_recent_posts_limit(site))
        writer.write_archive(target_path:)
        writer.write_year_indexes(target_path:)
        writer.write_month_rollups(target_path:)
      end

      private

      def gemini_recent_posts_limit(site)
        site.gemini_output_options&.recent_posts_limit || GeminiWriter::RECENT_POSTS_LIMIT
      end
    end

    Plugin = HTMLPlugin
  end
end
