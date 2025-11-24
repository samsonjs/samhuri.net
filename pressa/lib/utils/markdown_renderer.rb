require 'kramdown'
require 'yaml'
require_relative 'file_writer'
require_relative '../site'
require_relative '../views/layout'

class String
  include Phlex::SGML::SafeObject
end

module Pressa
  module Utils
    class MarkdownRenderer
      EXCERPT_LENGTH = 300

      def can_render_file?(filename:, extension:)
        extension == 'md'
      end

      def render(site:, file_path:, target_dir:)
        content = File.read(file_path)
        metadata, body_markdown = parse_content(content)

        html_body = render_markdown(body_markdown)

        page_title = presence(metadata['Title']) || File.basename(file_path, '.md').capitalize
        page_type = presence(metadata['Page type']) || 'website'
        page_description = presence(metadata['Description']) || generate_excerpt(body_markdown)
        show_extension = ['true', 'yes', true].include?(metadata['Show extension'])

        slug = File.basename(file_path, '.md')

        relative_dir = File.dirname(file_path).sub(/^.*?\/public\/?/, '')
        relative_dir = '' if relative_dir == '.'

        canonical_path = if show_extension
                           "/#{relative_dir}/#{slug}.html".squeeze('/')
                         else
                           "/#{relative_dir}/#{slug}/".squeeze('/')
                         end

        html = render_layout(
          site:,
          page_subtitle: page_title,
          canonical_url: site.url_for(canonical_path),
          body: html_body,
          page_description:,
          page_type:
        )

        output_filename = if show_extension
                            "#{slug}.html"
                          else
                            File.join(slug, 'index.html')
                          end

        output_path = File.join(target_dir, output_filename)
        FileWriter.write(path: output_path, content: html)
      end

      private

      def parse_content(content)
        if content =~ /\A---\s*\n(.*?)\n---\s*\n(.*)/m
          yaml_content = $1
          markdown = $2
          metadata = YAML.safe_load(yaml_content) || {}
          [metadata, markdown]
        else
          [{}, content]
        end
      end

      def render_markdown(markdown)
        Kramdown::Document.new(
          markdown,
          input: 'GFM',
          syntax_highlighter: 'rouge',
          syntax_highlighter_opts: {
            line_numbers: false,
            wrap: true
          }
        ).to_html
      end

      def render_layout(site:, page_subtitle:, canonical_url:, body:, page_description:, page_type:)
        layout = Views::Layout.new(
          site:,
          page_subtitle:,
          canonical_url:,
          page_description:,
          page_type:
        )

        content_view = PageView.new(page_title: page_subtitle, body:)
        layout.call do
          content_view.call
        end
      end

      class PageView < Phlex::HTML
        def initialize(page_title:, body:)
          @page_title = page_title
          @body = body
        end

        def view_template
          article(class: 'container') do
            h1 { @page_title }
            raw(@body)
          end

          div(class: 'row clearfix') do
            p(class: 'fin') do
              i(class: 'fa fa-code')
            end
          end
        end
      end

      def generate_excerpt(markdown)
        text = markdown.dup

        # Drop inline and reference-style images before links are simplified.
        text.gsub!(/!\[[^\]]*\]\([^)]+\)/, '')
        text.gsub!(/!\[[^\]]*\]\[[^\]]+\]/, '')

        # Replace inline and reference links with just their text.
        text.gsub!(/\[([^\]]+)\]\([^)]+\)/, '\1')
        text.gsub!(/\[([^\]]+)\]\[[^\]]+\]/, '\1')

        # Remove link reference definitions such as: [foo]: http://example.com
        text.gsub!(/(?m)^\[[^\]]+\]:\s*\S.*$/, '')

        text.gsub!(/<[^>]+>/, '')
        text.gsub!(/\s+/, ' ')
        text.strip!

        return nil if text.empty?

        "#{text[0...EXCERPT_LENGTH]}..."
      end

      def presence(value)
        return value unless value.respond_to?(:strip)

        stripped = value.strip
        stripped.empty? ? nil : stripped
      end
    end
  end
end
