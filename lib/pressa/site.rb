require "dry-struct"

module Pressa
  module Types
    include Dry.Types()
  end

  class OutputLink < Dry::Struct
    # label is required for HTML remote links, but Gemini home_links may omit it.
    attribute :label, Types::String.optional.default(nil)
    attribute :href, Types::String
    attribute :icon, Types::String.optional.default(nil)
  end

  class Script < Dry::Struct
    attribute :src, Types::String
    attribute :defer, Types::Bool.default(true)
  end

  class Stylesheet < Dry::Struct
    attribute :href, Types::String
  end

  class OutputOptions < Dry::Struct
    attribute :public_excludes, Types::Array.of(Types::String).default([].freeze)
  end

  class HTMLOutputOptions < OutputOptions
    attribute :remote_links, Types::Array.of(OutputLink).default([].freeze)
  end

  class GeminiOutputOptions < OutputOptions
    attribute :recent_posts_limit, Types::Integer.default(20)
    attribute :home_links, Types::Array.of(OutputLink).default([].freeze)
  end

  class Site < Dry::Struct
    OUTPUT_OPTIONS = Types.Instance(OutputOptions)

    attribute :author, Types::String
    attribute :email, Types::String
    attribute :title, Types::String
    attribute :description, Types::String
    attribute :url, Types::String
    attribute :fediverse_creator, Types::String.optional.default(nil)
    attribute :image_url, Types::String.optional.default(nil)
    attribute :copyright_start_year, Types::Integer.optional.default(nil)
    attribute :scripts, Types::Array.of(Script).default([].freeze)
    attribute :styles, Types::Array.of(Stylesheet).default([].freeze)
    attribute :plugins, Types::Array.default([].freeze)
    attribute :renderers, Types::Array.default([].freeze)
    attribute :output_format, Types::String.default("html".freeze).enum("html", "gemini")
    attribute :output_options, OUTPUT_OPTIONS.default { HTMLOutputOptions.new }

    def url_for(path)
      "#{url}#{path}"
    end

    def image_url_for(path)
      return nil unless image_url
      "#{image_url}#{path}"
    end

    def public_excludes
      output_options.public_excludes
    end

    def html_output_options
      output_options if output_options.is_a?(HTMLOutputOptions)
    end

    def gemini_output_options
      output_options if output_options.is_a?(GeminiOutputOptions)
    end
  end
end
