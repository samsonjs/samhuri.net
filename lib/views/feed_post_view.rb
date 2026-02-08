require 'phlex'

module Pressa
  module Views
    class FeedPostView < Phlex::HTML
      def initialize(post:, site:)
        @post = post
        @site = site
      end

      def view_template
        div do
          p(class: 'time') { @post.formatted_date }
          raw(@post.body)
          p do
            a(class: 'permalink', href: @site.url_for(@post.path)) { '∞' }
          end
        end
      end

      private
    end
  end
end
