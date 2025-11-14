require 'phlex'

class String
  include Phlex::SGML::SafeObject
end

module Pressa
  module Views
    class PostView < Phlex::HTML
      def initialize(post:, site:, article_class: nil)
        @post = post
        @site = site
        @article_class = article_class
      end

      def view_template
        article(**article_attributes) do
          header do
            h2 do
              if @post.link_post?
                a(href: @post.link) { "→ #{@post.title}" }
              else
                a(href: @post.path) { @post.title }
              end
            end
            time { @post.formatted_date }
            a(href: @post.path, class: 'permalink') { '∞' }
          end

          raw(@post.body)
        end

        div(class: 'row clearfix') do
          p(class: 'fin') do
            i(class: 'fa fa-code')
          end
        end
      end

      private

      def article_attributes
        return {} unless @article_class

        { class: @article_class }
      end
    end
  end
end
