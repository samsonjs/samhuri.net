require "cgi"

module Pressa
  module Utils
    class GemtextRenderer
      class << self
        def render(markdown)
          lines = markdown.to_s.gsub("\r\n", "\n").split("\n")
          link_reference_definitions = extract_link_reference_definitions(lines)
          output_lines = []
          in_preformatted_block = false

          lines.each do |line|
            if line.start_with?("```")
              output_lines << "```"
              in_preformatted_block = !in_preformatted_block
              next
            end

            if in_preformatted_block
              output_lines << line
              next
            end

            next if link_reference_definition?(line)

            converted_lines = convert_line(line, link_reference_definitions)
            output_lines.concat(converted_lines)
          end

          squish_blank_lines(output_lines).join("\n").strip
        end

        private

        def convert_line(line, link_reference_definitions)
          stripped = line.strip
          return [""] if stripped.empty?

          return convert_heading(stripped, link_reference_definitions) if heading_line?(stripped)
          return convert_list_item(stripped, link_reference_definitions) if list_item_line?(stripped)
          return convert_quote_line(stripped, link_reference_definitions) if quote_line?(stripped)

          convert_text_line(line, link_reference_definitions)
        end

        def convert_heading(line, link_reference_definitions)
          marker, text = line.split(/\s+/, 2)
          heading_text, links = extract_links(text.to_s, link_reference_definitions)
          rows = []
          rows << "#{marker} #{clean_inline_text(heading_text)}".strip
          rows.concat(render_link_rows(links))
          rows
        end

        def convert_list_item(line, link_reference_definitions)
          text = line.sub(/\A[-*+]\s+/, "")
          if link_only_list_item?(text, link_reference_definitions)
            _clean_text, links = extract_links(text, link_reference_definitions)
            return render_link_rows(links)
          end

          clean_text, links = extract_links(text, link_reference_definitions)
          rows = []
          rows << "* #{clean_inline_text(clean_text)}".strip
          rows.concat(render_link_rows(links))
          rows
        end

        def convert_quote_line(line, link_reference_definitions)
          text = line.sub(/\A>\s?/, "")
          clean_text, links = extract_links(text, link_reference_definitions)
          rows = []
          rows << "> #{clean_inline_text(clean_text)}".strip
          rows.concat(render_link_rows(links))
          rows
        end

        def convert_text_line(line, link_reference_definitions)
          clean_text, links = extract_links(line, link_reference_definitions)
          rows = []
          inline_text = clean_inline_text(clean_text)
          rows << inline_text unless inline_text.empty?
          rows.concat(render_link_rows(links))
          rows.empty? ? [""] : rows
        end

        def extract_links(text, link_reference_definitions)
          links = []
          work = text.dup

          work.gsub!(%r{<a\s+[^>]*href=["']([^"']+)["'][^>]*>(.*?)</a>}i) do
            url = Regexp.last_match(1)
            label = clean_inline_text(strip_html_tags(Regexp.last_match(2)))
            links << [url, label]
            label
          end

          work.gsub!(/\[([^\]]+)\]\(([^)\s]+)(?:\s+"[^"]*")?\)/) do
            label = clean_inline_text(Regexp.last_match(1))
            url = Regexp.last_match(2)
            links << [url, label]
            label
          end

          work.gsub!(/\[([^\]]+)\]\[([^\]]*)\]/) do
            label_text = Regexp.last_match(1)
            reference_key = Regexp.last_match(2)
            reference_key = label_text if reference_key.strip.empty?
            url = resolve_link_reference(link_reference_definitions, reference_key)
            next Regexp.last_match(0) unless url

            label = clean_inline_text(label_text)
            links << [url, label]
            label
          end

          work.scan(/(?:href|src)=["']([^"']+)["']/i) do |match|
            url = match.first
            next if links.any? { |(existing_url, _)| existing_url == url }

            links << [url, fallback_label(url)]
          end

          [work, links]
        end

        def resolve_link_reference(link_reference_definitions, key)
          link_reference_definitions[normalize_link_reference_key(key)]
        end

        def link_only_list_item?(text, link_reference_definitions)
          clean_text, links = extract_links(text, link_reference_definitions)
          return false if links.empty?

          remaining_text = strip_links_from_text(text)
          normalized_remaining = clean_inline_text(remaining_text)
          return true if normalized_remaining.empty?

          links_count = links.length
          links_count == 1 && normalized_remaining.match?(/\A[\w@.+\-\/ ]+:\z/)
        end

        def extract_link_reference_definitions(lines)
          links = {}
          lines.each do |line|
            match = line.match(/\A\s{0,3}\[([^\]]+)\]:\s*(\S+)/)
            next unless match

            key = normalize_link_reference_key(match[1])
            value = match[2]
            value = value[1..-2] if value.start_with?("<") && value.end_with?(">")
            links[key] = value
          end
          links
        end

        def normalize_link_reference_key(key)
          key.to_s.strip.downcase.gsub(/\s+/, " ")
        end

        def strip_links_from_text(text)
          work = text.dup
          work.gsub!(%r{<a\s+[^>]*href=["'][^"']+["'][^>]*>.*?</a>}i, "")
          work.gsub!(/\[([^\]]+)\]\(([^)\s]+)(?:\s+"[^"]*")?\)/, "")
          work.gsub!(/\[([^\]]+)\]\[([^\]]*)\]/, "")
          work
        end

        def render_link_rows(links)
          links.filter_map do |url, label|
            next nil if url.nil? || url.strip.empty?
            "=> #{url}"
          end
        end

        def clean_inline_text(text)
          cleaned = text.to_s.dup
          cleaned = strip_html_tags(cleaned)
          cleaned.gsub!(/`([^`]+)`/, '\1')
          cleaned.gsub!(/\*\*([^*]+)\*\*/, '\1')
          cleaned.gsub!(/__([^_]+)__/, '\1')
          cleaned.gsub!(/\*([^*]+)\*/, '\1')
          cleaned.gsub!(/_([^_]+)_/, '\1')
          cleaned.gsub!(/\s+/, " ")
          CGI.unescapeHTML(cleaned).strip
        end

        def strip_html_tags(text)
          text.gsub(/<[^>]+>/, "")
        end

        def fallback_label(url)
          uri_path = url.split("?").first
          basename = File.basename(uri_path.to_s)
          return url if basename.nil? || basename.empty? || basename == "/"

          basename
        end

        def heading_line?(line)
          line.match?(/\A\#{1,3}\s+/)
        end

        def list_item_line?(line)
          line.match?(/\A[-*+]\s+/)
        end

        def quote_line?(line)
          line.start_with?(">")
        end

        def link_reference_definition?(line)
          line.match?(/\A\s{0,3}\[[^\]]+\]:\s+\S/)
        end

        def squish_blank_lines(lines)
          output = []
          previous_blank = false

          lines.each do |line|
            blank = line.strip.empty?
            next if blank && previous_blank

            output << line
            previous_blank = blank
          end

          output
        end
      end
    end
  end
end
