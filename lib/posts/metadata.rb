require "yaml"
require "date"

module Pressa
  module Posts
    class PostMetadata
      REQUIRED_FIELDS = %w[Title Author Date Timestamp].freeze

      attr_reader :title, :author, :date, :formatted_date, :link, :tags, :scripts, :styles

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
        @scripts = parse_scripts(@raw["Scripts"])
        @styles = parse_styles(@raw["Styles"])
      end

      def parse_tags(value)
        return [] if value.nil?
        value.is_a?(Array) ? value : value.split(",").map(&:strip)
      end

      def parse_comma_separated(value)
        return [] if value.nil? || value.empty?
        value.split(",").map(&:strip)
      end

      def parse_scripts(value)
        return [] if value.nil?

        parse_comma_separated(value).map do |src|
          Script.new(src: normalize_asset_path(src, "js"), defer: true)
        end
      end

      def parse_styles(value)
        return [] if value.nil?

        parse_comma_separated(value).map do |href|
          Stylesheet.new(href: normalize_asset_path(href, "css"))
        end
      end

      def normalize_asset_path(path, default_dir)
        return path if path.start_with?("http://", "https://", "/")
        return path if path.include?("/")

        "#{default_dir}/#{path}"
      end
    end
  end
end
