require "yaml"
require "date"

module Pressa
  module Posts
    class PostMetadata
      REQUIRED_FIELDS = %w[Title Author Date Timestamp].freeze

      attr_reader :title, :author, :date, :formatted_date, :link, :tags

      def initialize(yaml_hash)
        @raw = yaml_hash
        validate_required_fields!
        parse_fields
      end

      def self.parse(content)
        if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
          yaml_content = $1
          yaml_hash = YAML.safe_load(yaml_content, permitted_classes: [Date, Time])
          new(yaml_hash)
        else
          raise "No YAML front-matter found in post"
        end
      end

      private

      def validate_required_fields!
        missing = REQUIRED_FIELDS.reject { |field| @raw.key?(field) }
        raise "Missing required fields: #{missing.join(", ")}" unless missing.empty?
      end

      def parse_fields
        @title = @raw["Title"]
        @author = @raw["Author"]
        timestamp = @raw["Timestamp"]
        @date = timestamp.is_a?(String) ? DateTime.parse(timestamp) : timestamp.to_datetime
        @formatted_date = @raw["Date"]
        @link = @raw["Link"]
        @tags = parse_tags(@raw["Tags"])
      end

      def parse_tags(value)
        return [] if value.nil?
        value.is_a?(Array) ? value : value.split(",").map(&:strip)
      end
    end
  end
end
