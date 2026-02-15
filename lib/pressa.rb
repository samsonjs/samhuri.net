require "pressa/site"
require "pressa/site_generator"
require "pressa/plugin"
require "pressa/posts/plugin"
require "pressa/projects/plugin"
require "pressa/utils/markdown_renderer"
require "pressa/utils/gemini_markdown_renderer"
require "pressa/config/loader"

module Pressa
  def self.create_site(source_path: ".", url_override: nil, output_format: "html")
    loader = Config::Loader.new(source_path:)
    loader.build_site(url_override:, output_format:)
  end
end
