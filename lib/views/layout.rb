require 'phlex'
require_relative 'icons'

module Pressa
  module Views
    class Layout < Phlex::HTML
      START_YEAR = 2006

      attr_reader :site,
                  :page_subtitle,
                  :page_description,
                  :page_type,
                  :canonical_url,
                  :page_scripts,
                  :page_styles,
                  :content

      def initialize(
        site:,
        page_subtitle: nil,
        canonical_url:,
        page_description: nil,
        page_type: 'website',
        page_scripts: [],
        page_styles: [],
        content: nil
      )
        @site = site
        @page_subtitle = page_subtitle
        @page_description = page_description
        @page_type = page_type
        @canonical_url = canonical_url
        @page_scripts = page_scripts
        @page_styles = page_styles
        @content = content
      end

      def format_output?
        true
      end

      def view_template
        doctype

        html(lang: 'en') do
          comment { 'meow' }

          head do
            meta(charset: 'UTF-8')
            title { full_title }
            meta(name: 'twitter:title', content: full_title)
            meta(property: 'og:title', content: full_title)
            meta(name: 'description', content: description)
            meta(name: 'twitter:description', content: description)
            meta(property: 'og:description', content: description)
            meta(property: 'og:site_name', content: site.title)

            link(rel: 'canonical', href: canonical_url)
            meta(name: 'twitter:url', content: canonical_url)
            meta(property: 'og:url', content: canonical_url)
            meta(property: 'og:image', content: og_image_url) if og_image_url
            meta(property: 'og:type', content: page_type)
            meta(property: 'article:author', content: site.author)
            meta(name: 'twitter:card', content: 'summary')

            link(
              rel: 'alternate',
              href: site.url_for('/feed.xml'),
              type: 'application/rss+xml',
              title: site.title
            )
            link(
              rel: 'alternate',
              href: site.url_for('/feed.json'),
              type: 'application/json',
              title: site.title
            )

            meta(name: 'fediverse:creator', content: '@sjs@techhub.social')
            link(rel: 'author', type: 'text/plain', href: site.url_for('/humans.txt'))
            link(rel: 'icon', type: 'image/png', href: site.url_for('/images/favicon-32x32.png'))
            link(rel: 'shortcut icon', href: site.url_for('/images/favicon.icon'))
            link(rel: 'apple-touch-icon', href: site.url_for('/images/apple-touch-icon.png'))
            link(rel: 'mask-icon', color: '#aa0000', href: site.url_for('/images/safari-pinned-tab.svg'))
            link(rel: 'manifest', href: site.url_for('/images/manifest.json'))
            meta(name: 'msapplication-config', content: site.url_for('/images/browserconfig.xml'))
            meta(name: 'theme-color', content: '#121212')
            meta(name: 'viewport', content: 'width=device-width, initial-scale=1.0, viewport-fit=cover')
            link(rel: 'dns-prefetch', href: 'https://gist.github.com')

            all_styles.each do |style|
              link(rel: 'stylesheet', type: 'text/css', href: absolute_asset(style.href))
            end
          end

          body do
            render_header
            render(content) if content
            render_footer
            render_scripts
          end
        end
      end

      private

      def description
        page_description || site.description
      end

      def full_title
        return site.title unless page_subtitle

        "#{site.title}: #{page_subtitle}"
      end

      def og_image_url
        site.image_url
      end

      def all_styles
        site.styles + page_styles
      end

      def all_scripts
        site.scripts + page_scripts
      end

      def render_header
        header(class: 'primary') do
          div(class: 'title') do
            h1 do
              a(href: site.url) { site.title }
            end
            br
            h4 do
              plain 'By '
              a(href: site.url_for('/about')) { site.author }
            end
          end

          nav(class: 'remote') do
            ul do
              li(class: 'mastodon') do
                a(rel: 'me', 'aria-label': 'Mastodon', href: 'https://techhub.social/@sjs') do
                  raw(safe(Icons.mastodon))
                end
              end
              li(class: 'github') do
                a('aria-label': 'GitHub', href: 'https://github.com/samsonjs') do
                  raw(safe(Icons.github))
                end
              end
              li(class: 'rss') do
                a('aria-label': 'RSS', href: site.url_for('/feed.xml')) do
                  raw(safe(Icons.rss))
                end
              end
            end
          end

          nav(class: 'local') do
            ul do
              li { a(href: site.url_for('/about')) { 'About' } }
              li { a(href: site.url_for('/posts')) { 'Archive' } }
              li { a(href: site.url_for('/projects')) { 'Projects' } }
            end
          end

          div(class: 'clearfix')
        end
      end

      def render_footer
        footer do
          plain "© #{START_YEAR} - #{Time.now.year} "
          a(href: site.url_for('/about')) { site.author }
        end
      end

      def render_scripts
        all_scripts.each do |scr|
          attrs = { src: script_src(scr.src) }
          attrs[:defer] = true if scr.defer
          script(**attrs)
        end
      end

      def script_src(src)
        return src if src.start_with?('http://', 'https://')

        absolute_asset(src)
      end

      def absolute_asset(path)
        normalized = path.start_with?('/') ? path : "/#{path}"
        site.url_for(normalized)
      end
    end
  end
end
