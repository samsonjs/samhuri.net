require "dry-struct"
require "pressa/site"

module Pressa
  module Projects
    class Project < Dry::Struct
      attribute :name, Types::String
      attribute :title, Types::String
      attribute :description, Types::String
      attribute :url, Types::String

      def github_path
        uri = URI.parse(url)
        uri.path.sub(/^\//, "")
      end

      def path
        "/projects/#{name}"
      end
    end
  end
end
