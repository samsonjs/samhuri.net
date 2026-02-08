require "spec_helper"
require "fileutils"
require "tmpdir"

RSpec.describe Pressa::Config::Loader do
  describe "#build_site" do
    it "builds a site from site.toml and projects.toml" do
      with_temp_config do |dir|
        loader = described_class.new(source_path: dir)
        site = loader.build_site

        expect(site.author).to eq("Sami Samhuri")
        expect(site.url).to eq("https://samhuri.net")
        expect(site.image_url).to eq("https://samhuri.net/images/me.jpg")
        expect(site.styles.map(&:href)).to eq(["css/style.css"])

        projects_plugin = site.plugins.find { |plugin| plugin.is_a?(Pressa::Projects::Plugin) }
        expect(projects_plugin).not_to be_nil
        expect(projects_plugin.scripts.map(&:src)).to eq(["js/projects.js"])
      end
    end

    it "applies url_override and rewrites relative image_url with override host" do
      with_temp_config do |dir|
        loader = described_class.new(source_path: dir)
        site = loader.build_site(url_override: "https://beta.samhuri.net")

        expect(site.url).to eq("https://beta.samhuri.net")
        expect(site.image_url).to eq("https://beta.samhuri.net/images/me.jpg")
      end
    end

    it "raises a validation error for missing required site keys" do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "site.toml"), "title = \"x\"\n")
        File.write(File.join(dir, "projects.toml"), "")

        loader = described_class.new(source_path: dir)
        expect { loader.build_site }.to raise_error(Pressa::Config::ValidationError, /Missing required site\.toml keys/)
      end
    end
  end

  def with_temp_config
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        image_url = "/images/me.jpg"
        scripts = []
        styles = ["css/style.css"]

        [projects_plugin]
        scripts = ["js/projects.js"]
        styles = []
      TOML

      File.write(File.join(dir, "projects.toml"), <<~TOML)
        [[projects]]
        name = "demo"
        title = "demo"
        description = "demo project"
        url = "https://github.com/samsonjs/demo"
      TOML

      yield dir
    end
  end
end
