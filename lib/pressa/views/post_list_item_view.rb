require "phlex"

module Pressa
  module Views
    class PostListItemView < Phlex::HTML
      def initialize(post:)
        @post = post
      end

      def view_template
        if @post.link_post?
          li do
            a(href: @post.link) { "→ #{@post.title}" }
            time { short_date(@post.date) }
            a(class: "permalink", href: @post.path) { "∞" }
          end
        else
          li do
            a(href: @post.path) { @post.title }
            time { short_date(@post.date) }
          end
        end
      end

      private

      def short_date(date)
        date.strftime("%-d %b %Y")
      end
    end
  end
end
