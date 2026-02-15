require "yaml"
require "pressa/utils/file_writer"
require "pressa/utils/gemtext_renderer"

module Pressa
  module Utils
    class GeminiMarkdownRenderer
      def can_render_file?(filename:, extension:)
        extension == "md"
      end

      def render(site:, file_path:, target_dir:)
        content = File.read(file_path)
        metadata, body_markdown = parse_content(content)

        page_title = presence(metadata["Title"]) || File.basename(file_path, ".md").capitalize
        show_extension = ["true", "yes", true].include?(metadata["Show extension"])
        slug = File.basename(file_path, ".md")

        relative_dir = File.dirname(file_path).sub(/^.*?\/public\/?/, "")
        relative_dir = "" if relative_dir == "."

        canonical_html_path = if show_extension
          "/#{relative_dir}/#{slug}.html".squeeze("/")
        else
          "/#{relative_dir}/#{slug}/".squeeze("/")
        end

        rows = ["# #{page_title}", ""]
        gemtext_body = GemtextRenderer.render(body_markdown)
        rows << gemtext_body unless gemtext_body.empty?
        rows << "" unless rows.last.to_s.empty?
        rows << "=> #{site.url_for(canonical_html_path)} Read on the web"
        rows << ""

        output_filename = if show_extension
          "#{slug}.gmi"
        else
          File.join(slug, "index.gmi")
        end

        output_path = File.join(target_dir, output_filename)
        FileWriter.write(path: output_path, content: rows.join("\n"))
      end

      private

      def parse_content(content)
        if content =~ /\A---\s*\n(.*?)\n---\s*\n(.*)/m
          yaml_content = Regexp.last_match(1)
          markdown = Regexp.last_match(2)
          metadata = YAML.safe_load(yaml_content) || {}
          [metadata, markdown]
        else
          [{}, content]
        end
      end

      def presence(value)
        return value unless value.respond_to?(:strip)

        stripped = value.strip
        stripped.empty? ? nil : stripped
      end
    end
  end
end
