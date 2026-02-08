require "builder"
require_relative "../utils/file_writer"
require_relative "../views/feed_post_view"

module Pressa
  module Posts
    class RSSFeedWriter
      def initialize(site:, posts_by_year:)
        @site = site
        @posts_by_year = posts_by_year
      end

      def write_feed(target_path:, limit: 30)
        recent = @posts_by_year.recent_posts(limit)

        xml = Builder::XmlMarkup.new(indent: 2)
        xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

        xml.rss :version => "2.0",
          "xmlns:atom" => "http://www.w3.org/2005/Atom",
          "xmlns:content" => "http://purl.org/rss/1.0/modules/content/" do
          xml.channel do
            xml.title @site.title
            xml.link @site.url
            xml.description @site.description
            xml.pubDate recent.first.date.rfc822 if recent.any?
            xml.tag! "atom:link", href: @site.url_for("/feed.xml"), rel: "self", type: "application/rss+xml"

            recent.each do |post|
              xml.item do
                title = post.link_post? ? "→ #{post.title}" : post.title
                permalink = @site.url_for(post.path)
                xml.title title
                xml.link permalink
                xml.guid permalink, isPermaLink: "true"
                xml.pubDate post.date.rfc822
                xml.author post.author
                xml.tag!("content:encoded") { xml.cdata!(render_feed_post(post)) }
              end
            end
          end
        end

        file_path = File.join(target_path, "feed.xml")
        Utils::FileWriter.write(path: file_path, content: xml.target!)
      end

      def render_feed_post(post)
        Views::FeedPostView.new(post:, site: @site).call
      end
    end
  end
end
