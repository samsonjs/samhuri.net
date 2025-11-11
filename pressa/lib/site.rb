require 'dry-struct'

module Pressa
  module Types
    include Dry.Types()
  end

  class Script < Dry::Struct
    attribute :src, Types::String
    attribute :defer, Types::Bool.default(true)
  end

  class Stylesheet < Dry::Struct
    attribute :href, Types::String
  end

  class Site < Dry::Struct
    attribute :author, Types::String
    attribute :email, Types::String
    attribute :title, Types::String
    attribute :description, Types::String
    attribute :url, Types::String
    attribute :image_url, Types::String.optional.default(nil)
    attribute :scripts, Types::Array.of(Script).default([].freeze)
    attribute :styles, Types::Array.of(Stylesheet).default([].freeze)
    attribute :plugins, Types::Array.default([].freeze)
    attribute :renderers, Types::Array.default([].freeze)

    def url_for(path)
      "#{url}#{path}"
    end

    def image_url_for(path)
      return nil unless image_url
      "#{image_url}#{path}"
    end
  end
end
