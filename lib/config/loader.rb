require_relative "../site"
require_relative "../posts/plugin"
require_relative "../projects/plugin"
require_relative "../utils/markdown_renderer"
require_relative "simple_toml"

module Pressa
  module Config
    class ValidationError < StandardError; end

    class Loader
      REQUIRED_SITE_KEYS = %w[author email title description url].freeze
      REQUIRED_PROJECT_KEYS = %w[name title description url].freeze

      def initialize(source_path:)
        @source_path = source_path
      end

      def build_site(url_override: nil)
        site_config = load_toml("site.toml")
        projects_config = load_toml("projects.toml")

        validate_required!(site_config, REQUIRED_SITE_KEYS, context: "site.toml")

        site_url = url_override || site_config["url"]
        projects_plugin = hash_or_empty(site_config["projects_plugin"], "site.toml projects_plugin")

        projects = build_projects(projects_config)

        Site.new(
          author: site_config["author"],
          email: site_config["email"],
          title: site_config["title"],
          description: site_config["description"],
          url: site_url,
          image_url: normalize_image_url(site_config["image_url"], site_url),
          scripts: build_scripts(site_config["scripts"], context: "site.toml scripts"),
          styles: build_styles(site_config["styles"], context: "site.toml styles"),
          plugins: [
            Posts::Plugin.new,
            Projects::Plugin.new(
              projects:,
              scripts: build_scripts(projects_plugin["scripts"], context: "site.toml projects_plugin.scripts"),
              styles: build_styles(projects_plugin["styles"], context: "site.toml projects_plugin.styles")
            )
          ],
          renderers: [
            Utils::MarkdownRenderer.new
          ]
        )
      end

      private

      def load_toml(filename)
        path = File.join(@source_path, filename)
        SimpleToml.load_file(path)
      rescue ParseError => e
        raise ValidationError, e.message
      end

      def build_projects(projects_config)
        projects = projects_config["projects"]
        raise ValidationError, "Missing required top-level array 'projects' in projects.toml" unless projects
        raise ValidationError, "Expected 'projects' to be an array in projects.toml" unless projects.is_a?(Array)

        projects.map.with_index do |project, index|
          unless project.is_a?(Hash)
            raise ValidationError, "Project entry #{index + 1} must be a table in projects.toml"
          end

          validate_required!(project, REQUIRED_PROJECT_KEYS, context: "projects.toml project ##{index + 1}")

          Projects::Project.new(
            name: project["name"],
            title: project["title"],
            description: project["description"],
            url: project["url"]
          )
        end
      end

      def validate_required!(hash, keys, context:)
        missing = keys.reject do |key|
          hash[key].is_a?(String) && !hash[key].strip.empty?
        end

        return if missing.empty?

        raise ValidationError, "Missing required #{context} keys: #{missing.join(", ")}"
      end

      def hash_or_empty(value, context)
        return {} if value.nil?
        return value if value.is_a?(Hash)

        raise ValidationError, "Expected #{context} to be a table"
      end

      def build_scripts(value, context:)
        entries = array_or_empty(value, context)

        entries.map.with_index do |item, index|
          case item
          when String
            Script.new(src: item, defer: true)
          when Hash
            src = item["src"]
            raise ValidationError, "Expected #{context}[#{index}].src to be a String" unless src.is_a?(String) && !src.empty?

            defer = item.key?("defer") ? item["defer"] : true
            unless [true, false].include?(defer)
              raise ValidationError, "Expected #{context}[#{index}].defer to be a Boolean"
            end

            Script.new(src:, defer:)
          else
            raise ValidationError, "Expected #{context}[#{index}] to be a String or table"
          end
        end
      end

      def build_styles(value, context:)
        entries = array_or_empty(value, context)

        entries.map.with_index do |item, index|
          case item
          when String
            Stylesheet.new(href: item)
          when Hash
            href = item["href"]
            raise ValidationError, "Expected #{context}[#{index}].href to be a String" unless href.is_a?(String) && !href.empty?

            Stylesheet.new(href:)
          else
            raise ValidationError, "Expected #{context}[#{index}] to be a String or table"
          end
        end
      end

      def array_or_empty(value, context)
        return [] if value.nil?
        return value if value.is_a?(Array)

        raise ValidationError, "Expected #{context} to be an array"
      end

      def normalize_image_url(value, site_url)
        return nil if value.nil?
        return value if value.start_with?("http://", "https://")

        normalized = value.start_with?("/") ? value : "/#{value}"
        "#{site_url}#{normalized}"
      end
    end
  end
end
