require "dry-struct"
require "pressa/site"

module Pressa
  class Drafts
    class Entry < Dry::Struct
      attribute :slug, Types::String
      attribute :title, Types::String
      attribute :timestamp, Types::Params::DateTime
      attribute :path, Types::String
    end
  end
end
