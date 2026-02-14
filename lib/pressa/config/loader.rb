require "pressa/site"
require "pressa/posts/plugin"
require "pressa/projects/plugin"
require "pressa/utils/markdown_renderer"
require "pressa/utils/gemini_markdown_renderer"
require "pressa/config/simple_toml"

module Pressa
  module Config
    class ValidationError < StandardError; end

    class Loader
      REQUIRED_SITE_KEYS = %w[author email title description url].freeze
      REQUIRED_PROJECT_KEYS = %w[name title description url].freeze

      def initialize(source_path:)
        @source_path = source_path
      end

      def build_site(url_override: nil, output_format: "html")
        site_config = load_toml("site.toml")

        validate_required!(site_config, REQUIRED_SITE_KEYS, context: "site.toml")
        validate_no_legacy_output_keys!(site_config)

        normalized_output_format = normalize_output_format(output_format)
        site_url = url_override || site_config["url"]
        output_options = build_output_options(site_config:, output_format: normalized_output_format)
        plugins = build_plugins(site_config, output_format: normalized_output_format)

        Site.new(
          author: site_config["author"],
          email: site_config["email"],
          title: site_config["title"],
          description: site_config["description"],
          url: site_url,
          fediverse_creator: build_optional_string(
            site_config["fediverse_creator"],
            context: "site.toml fediverse_creator"
          ),
          image_url: normalize_image_url(site_config["image_url"], site_url),
          scripts: build_scripts(site_config["scripts"], context: "site.toml scripts"),
          styles: build_styles(site_config["styles"], context: "site.toml styles"),
          plugins:,
          renderers: build_renderers(output_format: normalized_output_format),
          output_format: normalized_output_format,
          output_options:
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

      def validate_no_legacy_output_keys!(site_config)
        if site_config.key?("output")
          raise ValidationError, "Legacy key 'output' is no longer supported; use 'outputs'"
        end

        if site_config.key?("mastodon_url") || site_config.key?("github_url")
          raise ValidationError, "Legacy keys 'mastodon_url'/'github_url' are no longer supported; use outputs.html.remote_links or outputs.gemini.home_links"
        end
      end

      def build_plugins(site_config, output_format:)
        plugin_names = parse_plugin_names(site_config["plugins"])

        plugin_names.map.with_index do |plugin_name, index|
          case plugin_name
          when "posts"
            posts_plugin_for(output_format)
          when "projects"
            build_projects_plugin(site_config, output_format:)
          else
            raise ValidationError, "Unknown plugin '#{plugin_name}' at site.toml plugins[#{index}]"
          end
        end
      end

      def build_renderers(output_format:)
        case output_format
        when "html"
          [Utils::MarkdownRenderer.new]
        when "gemini"
          [Utils::GeminiMarkdownRenderer.new]
        else
          raise ValidationError, "Unsupported output format '#{output_format}'"
        end
      end

      def posts_plugin_for(output_format)
        case output_format
        when "html"
          Posts::HTMLPlugin.new
        when "gemini"
          Posts::GeminiPlugin.new
        else
          raise ValidationError, "Unsupported output format '#{output_format}'"
        end
      end

      def parse_plugin_names(value)
        return [] if value.nil?
        raise ValidationError, "Expected site.toml plugins to be an array" unless value.is_a?(Array)

        seen = {}

        value.map.with_index do |plugin_name, index|
          unless plugin_name.is_a?(String) && !plugin_name.strip.empty?
            raise ValidationError, "Expected site.toml plugins[#{index}] to be a non-empty String"
          end

          normalized_plugin_name = plugin_name.strip
          if seen[normalized_plugin_name]
            raise ValidationError, "Duplicate plugin '#{normalized_plugin_name}' in site.toml plugins"
          end
          seen[normalized_plugin_name] = true

          normalized_plugin_name
        end
      end

      def build_projects_plugin(site_config, output_format:)
        projects_plugin = hash_or_empty(site_config["projects_plugin"], "site.toml projects_plugin")
        projects_config = load_toml("projects.toml")
        projects = build_projects(projects_config)

        case output_format
        when "html"
          Projects::HTMLPlugin.new(
            projects:,
            scripts: build_scripts(projects_plugin["scripts"], context: "site.toml projects_plugin.scripts"),
            styles: build_styles(projects_plugin["styles"], context: "site.toml projects_plugin.styles")
          )
        when "gemini"
          Projects::GeminiPlugin.new(projects:)
        else
          raise ValidationError, "Unsupported output format '#{output_format}'"
        end
      end

      def hash_or_empty(value, context)
        return {} if value.nil?
        return value if value.is_a?(Hash)

        raise ValidationError, "Expected #{context} to be a table"
      end

      def build_output_options(site_config:, output_format:)
        outputs_config = hash_or_empty(site_config["outputs"], "site.toml outputs")
        validate_allowed_keys!(
          outputs_config,
          allowed_keys: %w[html gemini],
          context: "site.toml outputs"
        )
        format_config = hash_or_empty(outputs_config[output_format], "site.toml outputs.#{output_format}")

        case output_format
        when "html"
          build_html_output_options(format_config:)
        when "gemini"
          build_gemini_output_options(format_config:)
        else
          raise ValidationError, "Unsupported output format '#{output_format}'"
        end
      end

      def build_html_output_options(format_config:)
        validate_allowed_keys!(
          format_config,
          allowed_keys: %w[exclude_public remote_links],
          context: "site.toml outputs.html"
        )
        public_excludes = build_public_excludes(
          format_config["exclude_public"],
          context: "site.toml outputs.html.exclude_public"
        )
        remote_links = build_output_links(
          format_config["remote_links"],
          context: "site.toml outputs.html.remote_links",
          allow_icon: true
        )

        HTMLOutputOptions.new(
          public_excludes:,
          remote_links:
        )
      end

      def build_gemini_output_options(format_config:)
        validate_allowed_keys!(
          format_config,
          allowed_keys: %w[exclude_public recent_posts_limit home_links],
          context: "site.toml outputs.gemini"
        )
        public_excludes = build_public_excludes(
          format_config["exclude_public"],
          context: "site.toml outputs.gemini.exclude_public"
        )
        home_links = build_output_links(
          format_config["home_links"],
          context: "site.toml outputs.gemini.home_links",
          allow_icon: false
        )
        recent_posts_limit = build_recent_posts_limit(
          format_config["recent_posts_limit"],
          context: "site.toml outputs.gemini.recent_posts_limit"
        )

        GeminiOutputOptions.new(
          public_excludes:,
          recent_posts_limit:,
          home_links:
        )
      end

      def build_scripts(value, context:)
        entries = array_or_empty(value, context)

        entries.map.with_index do |item, index|
          case item
          when String
            validate_asset_path!(
              item,
              context: "#{context}[#{index}]"
            )
            Script.new(src: item, defer: true)
          when Hash
            src = item["src"]
            raise ValidationError, "Expected #{context}[#{index}].src to be a String" unless src.is_a?(String) && !src.empty?
            validate_asset_path!(
              src,
              context: "#{context}[#{index}].src"
            )

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
            validate_asset_path!(
              item,
              context: "#{context}[#{index}]"
            )
            Stylesheet.new(href: item)
          when Hash
            href = item["href"]
            raise ValidationError, "Expected #{context}[#{index}].href to be a String" unless href.is_a?(String) && !href.empty?
            validate_asset_path!(
              href,
              context: "#{context}[#{index}].href"
            )

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

      def validate_asset_path!(value, context:)
        return if value.start_with?("/", "http://", "https://")

        raise ValidationError, "Expected #{context} to start with / or use http(s) scheme"
      end

      def build_public_excludes(value, context:)
        entries = array_or_empty(value, context)
        entries.map.with_index do |entry, index|
          unless entry.is_a?(String) && !entry.strip.empty?
            raise ValidationError, "Expected #{context}[#{index}] to be a non-empty String"
          end

          entry.strip
        end
      end

      def build_output_links(value, context:, allow_icon:)
        entries = array_or_empty(value, context)
        entries.map.with_index do |entry, index|
          unless entry.is_a?(Hash)
            raise ValidationError, "Expected #{context}[#{index}] to be a table"
          end

          allowed_keys = allow_icon ? %w[label href icon] : %w[label href]
          validate_allowed_keys!(
            entry,
            allowed_keys:,
            context: "#{context}[#{index}]"
          )

          label = entry["label"]
          href = entry["href"]
          unless label.is_a?(String) && !label.strip.empty?
            raise ValidationError, "Expected #{context}[#{index}].label to be a non-empty String"
          end
          unless href.is_a?(String) && !href.strip.empty?
            raise ValidationError, "Expected #{context}[#{index}].href to be a non-empty String"
          end
          validate_link_href!(href.strip, context: "#{context}[#{index}].href")

          icon = entry["icon"]
          unless allow_icon
            if entry.key?("icon")
              raise ValidationError, "Unexpected #{context}[#{index}].icon; icons are only supported for outputs.html.remote_links"
            end

            icon = nil
          end

          if allow_icon && !icon.nil? && (!icon.is_a?(String) || icon.strip.empty?)
            raise ValidationError, "Expected #{context}[#{index}].icon to be a non-empty String"
          end

          OutputLink.new(label: label.strip, href: href.strip, icon: icon&.strip)
        end
      end

      def validate_link_href!(value, context:)
        return if value.start_with?("/")
        return if value.match?(/\A[a-z][a-z0-9+\-.]*:/i)

        raise ValidationError, "Expected #{context} to start with / or include a URI scheme"
      end

      def build_recent_posts_limit(value, context:)
        return 20 if value.nil?
        return value if value.is_a?(Integer) && value.positive?

        raise ValidationError, "Expected #{context} to be a positive Integer"
      end

      def normalize_output_format(output_format)
        value = output_format.to_s.strip.downcase
        return value if %w[html gemini].include?(value)

        raise ValidationError, "Unsupported output format '#{output_format}'"
      end

      def build_optional_string(value, context:)
        return nil if value.nil?
        return value if value.is_a?(String) && !value.strip.empty?

        raise ValidationError, "Expected #{context} to be a non-empty String"
      end

      def validate_allowed_keys!(hash, allowed_keys:, context:)
        unknown = hash.keys - allowed_keys
        return if unknown.empty?

        raise ValidationError, "Unknown key(s) in #{context}: #{unknown.join(", ")}"
      end
    end
  end
end
