require 'kramdown'
require 'yaml'
require_relative 'file_writer'
require_relative '../views/layout'

class String
  include Phlex::SGML::SafeObject
end

module Pressa
  module Utils
    class MarkdownRenderer
      def can_render_file?(filename:, extension:)
        extension == 'md'
      end

      def render(site:, file_path:, target_dir:)
        content = File.read(file_path)
        metadata, body_markdown = parse_content(content)

        html_body = render_markdown(body_markdown)

        page_title = metadata['Title'] || File.basename(file_path, '.md').capitalize
        show_extension = metadata['Show extension'] == 'true'

        html = render_layout(
          site:,
          page_title:,
          canonical_url: site.url,
          body: html_body
        )

        output_filename = if show_extension
                            File.basename(file_path, '.md') + '.html'
                          else
                            File.join(File.basename(file_path, '.md'), 'index.html')
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
            wrap: false
          }
        ).to_html
      end

      def render_layout(site:, page_title:, canonical_url:, body:)
        layout = Views::Layout.new(
          site:,
          page_title: "#{page_title} – #{site.title}",
          canonical_url:
        )

        layout.call do
          article(class: "page") do
            h1 { page_title }
            raw(body)
            div(class: "fin") { "◼" }
          end
        end
      end
    end
  end
end
