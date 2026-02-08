require_relative "site"
require_relative "site_generator"
require_relative "plugin"
require_relative "posts/plugin"
require_relative "projects/plugin"
require_relative "utils/markdown_renderer"
require_relative "config/loader"

module Pressa
  def self.create_site(source_path: ".", url_override: nil)
    loader = Config::Loader.new(source_path:)
    loader.build_site(url_override:)
  end
end
