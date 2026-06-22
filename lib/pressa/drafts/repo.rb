require "yaml"
require "date"
require "pressa/drafts"
require "pressa/drafts/entry"

module Pressa
  class Drafts
    class Repo
      def initialize(dir:)
        @dir = dir
      end

      def read_entries
        Dir.glob(File.join(@dir, "*.md")).sort.filter_map { |file_path| read_entry(file_path) }
          .sort_by(&:timestamp)
          .reverse
      end

      private

      def read_entry(file_path)
        content = File.read(file_path)
        return nil unless content =~ /\A---\s*\n(.*?)\n---\s*\n/m

        metadata = YAML.safe_load($1, permitted_classes: [Date, Time]) || {}
        title = metadata["Title"]
        timestamp_value = metadata["Timestamp"]
        return nil unless title && timestamp_value

        slug = File.basename(file_path, ".md")
        timestamp = parse_timestamp(timestamp_value)

        Entry.new(slug:, title:, timestamp:, path: "/drafts/#{slug}/")
      end

      def parse_timestamp(value)
        case value
        when String
          DateTime.parse(value)
        when Integer
          Time.at(value).to_datetime
        else
          value.to_datetime
        end
      end
    end
  end
end
