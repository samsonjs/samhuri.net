require 'builder'
require_relative '../utils/file_writer'

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

        xml.rss version: "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
          xml.channel do
            xml.title @site.title
            xml.link @site.url
            xml.description @site.description
            xml.language "en-us"
            xml.pubDate recent.first.date.rfc822 if recent.any?
            xml.lastBuildDate Time.now.rfc822
            xml.tag! "atom:link", href: @site.url_for('/feed.xml'), rel: "self", type: "application/rss+xml"

            recent.each do |post|
              xml.item do
                title = post.link_post? ? "→ #{post.title}" : post.title
                xml.title title
                xml.link post.link_post? ? post.link : @site.url_for(post.path)
                xml.guid @site.url_for(post.path), isPermaLink: "true"
                xml.description { xml.cdata! post.body }
                xml.pubDate post.date.rfc822
                xml.author "#{@site.email} (#{@site.author})"

                post.tags.each do |tag|
                  xml.category tag
                end
              end
            end
          end
        end

        file_path = File.join(target_path, 'feed.xml')
        Utils::FileWriter.write(path: file_path, content: xml.target!)
      end
    end
  end
end
