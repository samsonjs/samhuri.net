module Pressa
  module Utils
    module HtmlFormatter
      INDENT = 2
      VOID_TAGS = %w[
        area base br col embed hr img input link meta param source track wbr
      ].freeze

      PLACEHOLDER_PREFIX = '%%PRESSA_PRESERVE_'
      PRESERVE_PATTERNS = [
        /<div class="typocode">.*?<\/div>/m,
        /<div class="pressa">.*?<\/div>/m,
        /<div class="language-[^"]*?highlighter-rouge">.*?<\/div>\s*<\/div>/m
      ].freeze

      def self.format(html)
        html_with_placeholders, preserved = preserve_sections(html)
        formatted = format_with_indentation(html_with_placeholders)
        restore_sections(formatted, preserved)
      end

      def self.format_with_indentation(html)
        indent_level = 0

        formatted_lines = split_lines(html).map do |line|
          stripped = line.strip
          next if stripped.empty?

          decrease_indent = closing_tag?(stripped)
          indent_level = [indent_level - INDENT, 0].max if decrease_indent

          content = tag_line?(stripped) ? stripped : line
          current_line = (' ' * indent_level) + content

          if tag_line?(stripped) && !decrease_indent && !void_tag?(stripped) && !self_closing?(stripped)
            indent_level += INDENT
          end

          current_line
        end

        formatted_lines.compact.join("\n")
      end

      def self.split_lines(html)
        html.gsub(/>\s*</, ">\n<").split("\n")
      end

      def self.tag_line?(line)
        line.start_with?('<') && !line.start_with?('<!')
      end

      def self.closing_tag?(line)
        line.start_with?('</')
      end

      def self.self_closing?(line)
        line.end_with?('/>') || line.include?('</')
      end

      def self.tag_name(line)
        line[%r{\A</?([^\s>/]+)}, 1]&.downcase
      end

      def self.void_tag?(line)
        VOID_TAGS.include?(tag_name(line))
      end

      def self.preserve_sections(html)
        preserved = {}
        index = 0

        PRESERVE_PATTERNS.each do |pattern|
          html = html.gsub(pattern) do |match|
            placeholder = "#{PLACEHOLDER_PREFIX}#{index}%%"
            preserved[placeholder] = match
            index += 1
            placeholder
          end
        end

        [html, preserved]
      end

      def self.restore_sections(html, preserved)
        preserved.reduce(html) do |content, (placeholder, original)|
          content.gsub(placeholder, original)
        end
      end
    end
  end
end
