require 'json'
require_relative '../utils/file_writer'

module Pressa
  module Posts
    class JSONFeedWriter
      FEED_VERSION = "https://jsonfeed.org/version/1.1"

      def initialize(site:, posts_by_year:)
        @site = site
        @posts_by_year = posts_by_year
      end

      def write_feed(target_path:, limit: 30)
        recent = @posts_by_year.recent_posts(limit)

        feed = {
          version: FEED_VERSION,
          title: @site.title,
          home_page_url: @site.url,
          feed_url: @site.url_for('/feed.json'),
          description: @site.description,
          authors: [
            {
              name: @site.author,
              url: @site.url
            }
          ],
          items: recent.map { |post| feed_item(post) }
        }

        json = JSON.pretty_generate(feed)
        file_path = File.join(target_path, 'feed.json')
        Utils::FileWriter.write(path: file_path, content: json)
      end

      private

      def feed_item(post)
        item = {
          id: @site.url_for(post.path),
          url: post.link_post? ? post.link : @site.url_for(post.path),
          title: post.link_post? ? "→ #{post.title}" : post.title,
          content_html: post.body,
          summary: post.excerpt,
          date_published: post.date.iso8601,
          authors: [
            {
              name: post.author
            }
          ]
        }

        item[:tags] = post.tags unless post.tags.empty?

        item
      end
    end
  end
end
