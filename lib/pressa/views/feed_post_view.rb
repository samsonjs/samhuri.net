require "phlex"

module Pressa
  module Views
    class FeedPostView < Phlex::HTML
      def initialize(post:, site:)
        @post = post
        @site = site
      end

      def view_template
        div do
          p(class: "time") { @post.formatted_date }
          raw(safe(normalized_body))
          p do
            a(class: "permalink", href: @site.url_for(@post.path)) { "∞" }
          end
        end
      end

      private

      def normalized_body
        @post.body.gsub(/(href|src)=(['"])(\/(?!\/)[^'"]*)\2/) do
          attr = Regexp.last_match(1)
          quote = Regexp.last_match(2)
          path = Regexp.last_match(3)
          %(#{attr}=#{quote}#{@site.url_for(path)}#{quote})
        end
      end
    end
  end
end
