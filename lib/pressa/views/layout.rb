require "phlex"
require "pressa/views/icons"

module Pressa
  module Views
    class Layout < Phlex::HTML
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
        canonical_url:, page_subtitle: nil,
        page_description: nil,
        page_type: "website",
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

      def view_template
        doctype

        html(lang: "en") do
          comment { "meow" }

          head do
            meta(charset: "UTF-8")
            title { full_title }
            meta(name: "twitter:title", content: full_title)
            meta(property: "og:title", content: full_title)
            meta(name: "description", content: description)
            meta(name: "twitter:description", content: description)
            meta(property: "og:description", content: description)
            meta(property: "og:site_name", content: site.title)

            link(rel: "canonical", href: canonical_url)
            meta(name: "twitter:url", content: canonical_url)
            meta(property: "og:url", content: canonical_url)
            meta(property: "og:image", content: og_image_url) if og_image_url
            meta(property: "og:type", content: page_type)
            meta(property: "article:author", content: site.author)
            meta(name: "twitter:card", content: "summary")

            link(
              rel: "alternate",
              href: site.url_for("/feed.xml"),
              type: "application/rss+xml",
              title: site.title
            )
            link(
              rel: "alternate",
              href: site.url_for("/feed.json"),
              type: "application/json",
              title: site.title
            )

            meta(name: "fediverse:creator", content: site.fediverse_creator) if site.fediverse_creator
            link(rel: "author", type: "text/plain", href: site.url_for("/humans.txt"))
            link(rel: "icon", type: "image/png", href: site.url_for("/images/favicon-32x32.png"))
            link(rel: "shortcut icon", href: site.url_for("/images/favicon.icon"))
            link(rel: "apple-touch-icon", href: site.url_for("/images/apple-touch-icon.png"))
            link(rel: "mask-icon", color: "#aa0000", href: site.url_for("/images/safari-pinned-tab.svg"))
            link(rel: "manifest", href: site.url_for("/images/manifest.json"))
            meta(name: "msapplication-config", content: site.url_for("/images/browserconfig.xml"))
            meta(name: "theme-color", content: "#121212")
            meta(name: "viewport", content: "width=device-width, initial-scale=1.0, viewport-fit=cover")
            link(rel: "dns-prefetch", href: "https://gist.github.com")

            all_styles.each do |style|
              link(rel: "stylesheet", type: "text/css", href: style_href(style.href))
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
        header(class: "primary") do
          div(class: "title") do
            h1 do
              a(href: site.url) { site.title }
            end
            br
            h4 do
              plain "By "
              a(href: site.url_for("/about")) { site.author }
            end
          end

          nav(class: "remote") do
            ul do
              html_remote_links.each do |link|
                li(class: remote_link_class(link)) do
                  attrs = {"aria-label": link.label, href: remote_link_href(link.href)}
                  attrs[:rel] = "me" if mastodon_link?(link)

                  a(**attrs) do
                    icon_markup = remote_link_icon_markup(link)
                    if icon_markup
                      raw(safe(icon_markup))
                    else
                      plain link.label
                    end
                  end
                end
              end
            end
          end

          nav(class: "local") do
            ul do
              li { a(href: site.url_for("/about")) { "About" } }
              li { a(href: site.url_for("/posts")) { "Archive" } }
              li { a(href: site.url_for("/projects")) { "Projects" } }
            end
          end

          div(class: "clearfix")
        end
      end

      def render_footer
        footer do
          plain "© #{footer_years} "
          a(href: site.url_for("/about")) { site.author }
        end
      end

      def render_scripts
        all_scripts.each do |scr|
          attrs = {src: script_src(scr.src)}
          attrs[:defer] = true if scr.defer
          script(**attrs)
        end
      end

      def script_src(src)
        return src if src.start_with?("http://", "https://")

        absolute_asset(src)
      end

      def style_href(href)
        return href if href.start_with?("http://", "https://")

        absolute_asset(href)
      end

      def absolute_asset(path)
        normalized = path.start_with?("/") ? path : "/#{path}"
        site.url_for(normalized)
      end

      def footer_years
        current_year = Time.now.year
        start_year = site.copyright_start_year || current_year
        return current_year.to_s if start_year >= current_year

        "#{start_year} - #{current_year}"
      end

      def html_remote_links
        site.html_output_options&.remote_links || []
      end

      def remote_link_href(href)
        return href if href.start_with?("http://", "https://")

        absolute_asset(href)
      end

      def remote_link_class(link)
        slug = link.icon || link.label.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
        "remote-link #{slug}"
      end

      def remote_link_icon_markup(link)
        icon_renderer = remote_link_icon_renderer(link.icon)
        return nil unless icon_renderer

        Icons.public_send(icon_renderer)
      end

      def remote_link_icon_renderer(icon)
        case icon
        when "mastodon" then :mastodon
        when "github" then :github
        when "rss" then :rss
        when "code" then :code
        end
      end

      def mastodon_link?(link)
        link.icon == "mastodon"
      end
    end
  end
end
