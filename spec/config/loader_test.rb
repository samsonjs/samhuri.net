require "test_helper"
require "fileutils"
require "tmpdir"

class Pressa::Config::LoaderTest < Minitest::Test
  def test_build_site_builds_a_site_from_site_toml_and_projects_toml
    with_temp_config do |dir|
      loader = Pressa::Config::Loader.new(source_path: dir)
      site = loader.build_site

      assert_equal("Sami Samhuri", site.author)
      assert_equal("https://samhuri.net", site.url)
      assert_equal("https://samhuri.net/images/me.jpg", site.image_url)
      assert_equal(["css/style.css"], site.styles.map(&:href))

      projects_plugin = site.plugins.find { |plugin| plugin.is_a?(Pressa::Projects::Plugin) }
      refute_nil(projects_plugin)
      assert_equal(["js/projects.js"], projects_plugin.scripts.map(&:src))
    end
  end

  def test_build_site_applies_url_override_and_rewrites_relative_image_url_with_override_host
    with_temp_config do |dir|
      loader = Pressa::Config::Loader.new(source_path: dir)
      site = loader.build_site(url_override: "https://beta.samhuri.net")

      assert_equal("https://beta.samhuri.net", site.url)
      assert_equal("https://beta.samhuri.net/images/me.jpg", site.image_url)
    end
  end

  def test_build_site_raises_a_validation_error_for_missing_required_site_keys
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), "title = \"x\"\n")
      File.write(File.join(dir, "projects.toml"), "")

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Missing required site\.toml keys/, error.message)
    end
  end

  private

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
