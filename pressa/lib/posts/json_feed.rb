require 'json'
require_relative '../utils/file_writer'
require_relative '../views/feed_post_view'

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

        feed = build_feed(recent)

        json = JSON.pretty_generate(feed)
        file_path = File.join(target_path, 'feed.json')
        Utils::FileWriter.write(path: file_path, content: json)
      end

      private

      def build_feed(posts)
        author = {
          name: @site.author,
          url: @site.url,
          avatar: @site.image_url
        }

        items = posts.map { |post| feed_item(post) }

        {
          icon: icon_url,
          favicon: favicon_url,
          items: items,
          home_page_url: @site.url,
          author:,
          version: FEED_VERSION,
          authors: [author],
          feed_url: @site.url_for('/feed.json'),
          language: 'en-CA',
          title: @site.title
        }
      end

      def icon_url
        @site.url_for('/images/apple-touch-icon-300.png')
      end

      def favicon_url
        @site.url_for('/images/apple-touch-icon-80.png')
      end

      def feed_item(post)
        content_html = Views::FeedPostView.new(post:, site: @site).call
        permalink = @site.url_for(post.path)

        item = {}
        item[:url] = post.link_post? ? post.link : permalink
        item[:tags] = post.tags unless post.tags.empty?
        item[:content_html] = content_html
        item[:title] = post.link_post? ? "→ #{post.title}" : post.title
        item[:author] = { name: post.author }
        item[:date_published] = post.date.iso8601
        item[:id] = permalink

        item
      end
    end
  end
end
