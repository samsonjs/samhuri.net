module Pressa
  module Utils
    class FrontmatterConverter
      FIELD_PATTERN = /^([A-Z][A-Za-z\s]+):\s*(.+)$/

      def self.convert_file(input_path, output_path = nil)
        content = File.read(input_path)
        converted = convert_content(content)

        if output_path
          File.write(output_path, converted)
        else
          File.write(input_path, converted)
        end
      end

      def self.convert_content(content)
        unless content.start_with?("---\n")
          raise "File does not start with front-matter delimiter"
        end

        parts = content.split(/^---\n/, 3)
        if parts.length < 3
          raise "Could not find end of front-matter"
        end

        frontmatter = parts[1]
        body = parts[2]

        yaml_frontmatter = convert_frontmatter_to_yaml(frontmatter)

        "---\n#{yaml_frontmatter}---\n#{body}"
      end

      def self.convert_frontmatter_to_yaml(frontmatter)
        fields = {}

        frontmatter.each_line do |line|
          line = line.strip
          next if line.empty?

          if line =~ FIELD_PATTERN
            field_name = $1.strip
            field_value = $2.strip

            fields[field_name] = field_value
          end
        end

        yaml_lines = []
        fields.each do |name, value|
          yaml_lines << format_yaml_field(name, value)
        end

        yaml_lines.join("\n") + "\n"
      end

      private_class_method def self.format_yaml_field(name, value)
        return "#{name}: #{value}" if name == 'Timestamp'

        if name == 'Tags'
          tags = value.split(',').map(&:strip)
          return "#{name}: [#{tags.join(', ')}]"
        end

        if name == 'Title'
          escaped_value = value.gsub('\\', '\\\\\\\\').gsub('"', '\\"')
          return "#{name}: \"#{escaped_value}\""
        end

        has_special_chars = value.include?('\\') || value.include?('"')
        needs_quoting = has_special_chars ||
                        (value.include?(':') && !value.start_with?('http')) ||
                        value.include?(',') ||
                        name == 'Date'

        if needs_quoting
          escaped_value = value.gsub('\\', '\\\\\\\\').gsub('"', '\\"')
          "#{name}: \"#{escaped_value}\""
        else
          "#{name}: #{value}"
        end
      end
    end
  end
end
