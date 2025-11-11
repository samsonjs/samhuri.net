require 'phlex'

class String
  include Phlex::SGML::SafeObject
end

module Pressa
  module Views
    class PostView < Phlex::HTML
      def initialize(post:, site:)
        @post = post
        @site = site
      end

      def view_template
        article(class: "post") do
          header do
            if @post.link_post?
              h1 do
                a(href: @post.link) { "→ #{@post.title}" }
              end
            else
              h1 { @post.title }
            end

            div(class: "post-meta") do
              time(datetime: @post.date.iso8601) { @post.formatted_date }
              plain " · "
              a(href: @site.url_for(@post.path), class: "permalink") { "Permalink" }
            end
          end

          div(class: "post-content") do
            raw(@post.body)
          end

          footer(class: "post-footer") do
            div(class: "fin") { "◼" }
          end
        end
      end
    end
  end
end
