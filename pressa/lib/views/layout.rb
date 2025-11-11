require 'phlex'

module Pressa
  module Views
    class Layout < Phlex::HTML
      attr_reader :site, :page_title, :canonical_url, :page_scripts, :page_styles

      def initialize(site:, page_title:, canonical_url:, page_scripts: [], page_styles: [])
        @site = site
        @page_title = page_title
        @canonical_url = canonical_url
        @page_scripts = page_scripts
        @page_styles = page_styles
      end

      def view_template(&block)
        doctype

        html(lang: "en") do
          head do
            meta(charset: "utf-8")
            meta(name: "viewport", content: "width=device-width, initial-scale=1")
            title { page_title }
            meta(name: "description", content: site.description)
            meta(name: "author", content: site.author)

            link(rel: "canonical", href: canonical_url)

            meta(property: "og:title", content: page_title)
            meta(property: "og:description", content: site.description)
            meta(property: "og:url", content: canonical_url)
            meta(property: "og:type", content: "website")
            if site.image_url
              meta(property: "og:image", content: site.image_url)
            end

            meta(name: "twitter:card", content: "summary")
            meta(name: "twitter:title", content: page_title)
            meta(name: "twitter:description", content: site.description)

            link(rel: "alternate", type: "application/rss+xml", title: "RSS Feed", href: site.url_for('/feed.xml'))
            link(rel: "alternate", type: "application/json", title: "JSON Feed", href: site.url_for('/feed.json'))

            all_styles.each do |style|
              link(rel: "stylesheet", href: site.url_for("/#{style.href}"))
            end
          end

          body do
            render_header
            main(&block)
            render_footer
            render_scripts
          end
        end
      end

      private

      def all_styles
        site.styles + page_styles
      end

      def all_scripts
        site.scripts + page_scripts
      end

      def render_header
        header do
          h1 { a(href: "/") { site.title } }
          nav do
            ul do
              li { a(href: "/") { "Home" } }
              li { a(href: "/posts/") { "Archive" } }
              li { a(href: "/projects/") { "Projects" } }
              li { a(href: "/about/") { "About" } }
            end
          end
        end
      end

      def render_footer
        footer do
          p { "© #{Time.now.year} #{site.author}" }
          p do
            plain "Email: "
            a(href: "mailto:#{site.email}") { site.email }
          end
        end
      end

      def render_scripts
        all_scripts.each do |script|
          if script.defer
            script_(src: site.url_for("/#{script.src}"), defer: true)
          else
            script_(src: site.url_for("/#{script.src}"))
          end
        end
      end
    end
  end
end
