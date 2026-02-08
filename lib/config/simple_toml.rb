require 'json'

module Pressa
  module Config
    class ParseError < StandardError; end

    class SimpleToml
      def self.load_file(path)
        new.parse(File.read(path))
      rescue Errno::ENOENT
        raise ParseError, "Config file not found: #{path}"
      end

      def parse(content)
        root = {}
        current_table = root
        lines = content.each_line.to_a

        line_index = 0
        while line_index < lines.length
          line = lines[line_index]
          line_number = line_index + 1
          source = strip_comments(line).strip
          if source.empty?
            line_index += 1
            next
          end

          if source =~ /\A\[\[(.+)\]\]\z/
            current_table = start_array_table(root, Regexp.last_match(1), line_number)
            line_index += 1
            next
          end

          if source =~ /\A\[(.+)\]\z/
            current_table = start_table(root, Regexp.last_match(1), line_number)
            line_index += 1
            next
          end

          key, raw_value = parse_assignment(source, line_number)
          while needs_continuation?(raw_value)
            line_index += 1
            raise ParseError, "Unterminated value for key '#{key}' at line #{line_number}" if line_index >= lines.length

            continuation = strip_comments(lines[line_index]).strip
            next if continuation.empty?

            raw_value = "#{raw_value} #{continuation}"
          end

          if current_table.key?(key)
            raise ParseError, "Duplicate key '#{key}' at line #{line_number}"
          end

          current_table[key] = parse_value(raw_value, line_number)
          line_index += 1
        end

        root
      end

      private

      def start_array_table(root, raw_path, line_number)
        keys = parse_path(raw_path, line_number)
        parent = ensure_path(root, keys[0..-2], line_number)
        table_name = keys.last

        parent[table_name] ||= []
        array = parent[table_name]
        unless array.is_a?(Array)
          raise ParseError, "Expected array for '[[#{raw_path}]]' at line #{line_number}"
        end

        table = {}
        array << table
        table
      end

      def start_table(root, raw_path, line_number)
        keys = parse_path(raw_path, line_number)
        ensure_path(root, keys, line_number)
      end

      def ensure_path(root, keys, line_number)
        cursor = root

        keys.each do |key|
          cursor[key] ||= {}
          unless cursor[key].is_a?(Hash)
            raise ParseError, "Expected table path '#{keys.join('.')}' at line #{line_number}"
          end

          cursor = cursor[key]
        end

        cursor
      end

      def parse_path(raw_path, line_number)
        keys = raw_path.split('.').map(&:strip)
        if keys.empty? || keys.any? { |part| part.empty? || part !~ /\A[A-Za-z0-9_]+\z/ }
          raise ParseError, "Invalid table path '#{raw_path}' at line #{line_number}"
        end
        keys
      end

      def parse_assignment(source, line_number)
        separator = index_of_unquoted(source, '=')
        raise ParseError, "Invalid assignment at line #{line_number}" unless separator

        key = source[0...separator].strip
        value = source[(separator + 1)..].strip

        if key.empty? || key !~ /\A[A-Za-z0-9_]+\z/
          raise ParseError, "Invalid key '#{key}' at line #{line_number}"
        end
        raise ParseError, "Missing value for key '#{key}' at line #{line_number}" if value.empty?

        [key, value]
      end

      def parse_value(raw_value, line_number)
        JSON.parse(raw_value)
      rescue JSON::ParserError
        raise ParseError, "Unsupported TOML value '#{raw_value}' at line #{line_number}"
      end

      def needs_continuation?(source)
        in_string = false
        escaped = false
        depth = 0

        source.each_char do |char|
          if in_string
            if escaped
              escaped = false
            elsif char == '\\'
              escaped = true
            elsif char == '"'
              in_string = false
            end

            next
          end

          case char
          when '"'
            in_string = true
          when '[', '{'
            depth += 1
          when ']', '}'
            depth -= 1
          end
        end

        in_string || depth.positive?
      end

      def strip_comments(line)
        output = +''
        in_string = false
        escaped = false

        line.each_char do |char|
          if in_string
            output << char

            if escaped
              escaped = false
            elsif char == '\\'
              escaped = true
            elsif char == '"'
              in_string = false
            end

            next
          end

          case char
          when '"'
            in_string = true
            output << char
          when '#'
            break
          else
            output << char
          end
        end

        output
      end

      def index_of_unquoted(source, target)
        in_string = false
        escaped = false

        source.each_char.with_index do |char, index|
          if in_string
            if escaped
              escaped = false
            elsif char == '\\'
              escaped = true
            elsif char == '"'
              in_string = false
            end

            next
          end

          if char == '"'
            in_string = true
            next
          end

          return index if char == target
        end

        nil
      end
    end
  end
end
