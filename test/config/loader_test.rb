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
      assert_equal(["/css/style.css"], site.styles.map(&:href))
      assert_equal(["Mastodon", "GitHub"], site.html_output_options&.remote_links&.map(&:label))

      projects_plugin = site.plugins.find { |plugin| plugin.is_a?(Pressa::Projects::Plugin) }
      refute_nil(projects_plugin)
      assert_equal(["/js/projects.js"], projects_plugin.scripts.map(&:src))
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

  def test_build_site_supports_gemini_output_format
    with_temp_config do |dir|
      loader = Pressa::Config::Loader.new(source_path: dir)
      site = loader.build_site(output_format: "gemini")

      assert_equal("gemini", site.output_format)
      assert(site.plugins.any? { |plugin| plugin.is_a?(Pressa::Posts::GeminiPlugin) })
      assert(site.plugins.any? { |plugin| plugin.is_a?(Pressa::Projects::GeminiPlugin) })
      assert_equal(["Pressa::Utils::GeminiMarkdownRenderer"], site.renderers.map(&:class).map(&:name))
      assert_equal(["tweets/**"], site.public_excludes)
      assert_equal(20, site.gemini_output_options&.recent_posts_limit)
      assert_equal(["/about/", "https://github.com/samsonjs"], site.gemini_output_options&.home_links&.map(&:href))
    end
  end

  def test_build_site_rejects_invalid_output_excludes
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"

        [outputs.gemini]
        exclude_public = [123]
      TOML
      File.write(File.join(dir, "projects.toml"), "projects = []\n")

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) do
        loader.build_site(output_format: "gemini")
      end
      assert_match(/exclude_public\[0\] to be a non-empty String/, error.message)
    end
  end

  def test_build_site_rejects_legacy_output_key
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"

        [output.gemini]
        exclude_public = ["tweets/**"]
      TOML
      File.write(File.join(dir, "projects.toml"), "projects = []\n")

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site(output_format: "gemini") }
      assert_match(/Legacy key 'output' is no longer supported/, error.message)
    end
  end

  def test_build_site_rejects_legacy_social_url_keys
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        mastodon_url = "https://example.social/@sami"
      TOML
      File.write(File.join(dir, "projects.toml"), "projects = []\n")

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Legacy keys 'mastodon_url'\/'github_url' are no longer supported/, error.message)
    end
  end

  def test_build_site_accepts_gemini_home_links
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        plugins = ["posts"]

        [outputs.gemini]
        recent_posts_limit = 15
        home_links = [
          {"label": "About", "href": "/about/"},
          {"label": "GitHub", "href": "https://github.com/samsonjs"}
        ]
      TOML
      File.write(File.join(dir, "projects.toml"), "projects = []\n")

      loader = Pressa::Config::Loader.new(source_path: dir)
      site = loader.build_site(output_format: "gemini")

      assert_equal(15, site.gemini_output_options&.recent_posts_limit)
      assert_equal(["About", "GitHub"], site.gemini_output_options&.home_links&.map(&:label))
      assert_equal(["/about/", "https://github.com/samsonjs"], site.gemini_output_options&.home_links&.map(&:href))
    end
  end

  def test_build_site_rejects_invalid_gemini_home_links
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"

        [outputs.gemini]
        home_links = [{"label": "About"}]
      TOML
      File.write(File.join(dir, "projects.toml"), "projects = []\n")

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site(output_format: "gemini") }
      assert_match(/outputs\.gemini\.home_links\[0\]\.href to be a non-empty String/, error.message)
    end
  end

  def test_build_site_rejects_invalid_recent_posts_limit
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"

        [outputs.gemini]
        recent_posts_limit = 0
      TOML
      File.write(File.join(dir, "projects.toml"), "projects = []\n")

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site(output_format: "gemini") }
      assert_match(/outputs\.gemini\.recent_posts_limit to be a positive Integer/, error.message)
    end
  end

  def test_build_site_rejects_invalid_html_remote_links
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"

        [outputs.html]
        remote_links = [{"label": "GitHub", "href": "github.com/samsonjs"}]
      TOML
      File.write(File.join(dir, "projects.toml"), "projects = []\n")

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/outputs\.html\.remote_links\[0\]\.href to start with \//, error.message)
    end
  end

  def test_build_site_rejects_unknown_gemini_output_keys
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"

        [outputs.gemini]
        something_else = true
      TOML
      File.write(File.join(dir, "projects.toml"), "projects = []\n")

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site(output_format: "gemini") }
      assert_match(/Unknown key\(s\) in site\.toml outputs\.gemini: something_else/, error.message)
    end
  end

  def test_build_site_rejects_unknown_gemini_home_link_keys
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"

        [outputs.gemini]
        home_links = [{"label": "About", "href": "/about/", "icon": "mastodon"}]
      TOML
      File.write(File.join(dir, "projects.toml"), "projects = []\n")

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site(output_format: "gemini") }
      assert_match(/Unknown key\(s\) in site\.toml outputs\.gemini\.home_links\[0\]: icon/, error.message)
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

  def test_build_site_defaults_to_no_plugins_when_plugins_key_is_missing
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
      TOML

      loader = Pressa::Config::Loader.new(source_path: dir)
      site = loader.build_site
      assert_empty(site.plugins)
    end
  end

  def test_build_site_raises_for_invalid_plugins_type
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        plugins = "posts"
      TOML

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Expected site\.toml plugins to be an array/, error.message)
    end
  end

  def test_build_site_raises_for_unknown_plugin_name
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        plugins = ["wat"]
      TOML

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Unknown plugin 'wat'/, error.message)
    end
  end

  def test_build_site_raises_for_empty_plugin_name
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        plugins = [""]
      TOML

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Expected site\.toml plugins\[0\] to be a non-empty String/, error.message)
    end
  end

  def test_build_site_raises_for_duplicate_plugins
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        plugins = ["posts", "posts"]
      TOML

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Duplicate plugin 'posts' in site\.toml plugins/, error.message)
    end
  end

  def test_build_site_raises_for_missing_projects_array
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        plugins = ["projects"]
      TOML
      File.write(File.join(dir, "projects.toml"), "title = \"no projects\"\n")

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Missing required top-level array 'projects'/, error.message)
    end
  end

  def test_build_site_raises_for_invalid_project_entries
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        plugins = ["projects"]
      TOML
      File.write(File.join(dir, "projects.toml"), <<~TOML)
        projects = [1]
      TOML

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Project entry 1 must be a table/, error.message)
    end
  end

  def test_build_site_raises_for_invalid_projects_plugin_type
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        plugins = ["projects"]
        projects_plugin = []
      TOML
      File.write(File.join(dir, "projects.toml"), <<~TOML)
        [[projects]]
        name = "demo"
        title = "demo"
        description = "demo project"
        url = "https://github.com/samsonjs/demo"
      TOML

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Expected site\.toml projects_plugin to be a table/, error.message)
    end
  end

  def test_build_site_raises_for_invalid_script_and_style_entries
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        scripts = [{}]
        styles = [123]
      TOML
      File.write(File.join(dir, "projects.toml"), <<~TOML)
        [[projects]]
        name = "demo"
        title = "demo"
        description = "demo project"
        url = "https://github.com/samsonjs/demo"
      TOML

      loader = Pressa::Config::Loader.new(source_path: dir)
      script_error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Expected site\.toml scripts\[0\]\.src to be a String/, script_error.message)

      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        scripts = []
        styles = [123]
      TOML
      style_error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Expected site\.toml styles\[0\] to be a String or table/, style_error.message)
    end
  end

  def test_build_site_accepts_script_hashes_and_absolute_image_url
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        image_url = "https://images.example.net/me.jpg"
        scripts = [{"src": "/js/site.js", "defer": false}]
        styles = [{"href": "/css/site.css"}]
        plugins = ["posts", "projects"]

        [projects_plugin]
        scripts = [{"src": "/js/projects.js", "defer": true}]
        styles = [{"href": "/css/projects.css"}]
      TOML
      File.write(File.join(dir, "projects.toml"), <<~TOML)
        [[projects]]
        name = "demo"
        title = "demo"
        description = "demo project"
        url = "https://github.com/samsonjs/demo"
      TOML

      loader = Pressa::Config::Loader.new(source_path: dir)
      site = loader.build_site

      assert_equal("https://images.example.net/me.jpg", site.image_url)
      assert_equal(["/js/site.js"], site.scripts.map(&:src))
      assert_equal([false], site.scripts.map(&:defer))
      assert_equal(["/css/site.css"], site.styles.map(&:href))
    end
  end

  def test_build_site_rewraps_toml_parse_errors_as_validation_errors
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), "author = \"unterminated\n")
      File.write(File.join(dir, "projects.toml"), <<~TOML)
        [[projects]]
        name = "demo"
        title = "demo"
        description = "demo project"
        url = "https://github.com/samsonjs/demo"
      TOML

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Unterminated value for key 'author'/, error.message)
    end
  end

  def test_build_site_rejects_non_boolean_defer_values
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        scripts = [{"src": "/js/site.js", "defer": "yes"}]
      TOML
      File.write(File.join(dir, "projects.toml"), <<~TOML)
        [[projects]]
        name = "demo"
        title = "demo"
        description = "demo project"
        url = "https://github.com/samsonjs/demo"
      TOML

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Expected site\.toml scripts\[0\]\.defer to be a Boolean/, error.message)
    end
  end

  def test_build_site_rejects_non_string_or_table_scripts_and_non_array_script_lists
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        scripts = [123]
      TOML
      File.write(File.join(dir, "projects.toml"), <<~TOML)
        [[projects]]
        name = "demo"
        title = "demo"
        description = "demo project"
        url = "https://github.com/samsonjs/demo"
      TOML

      loader = Pressa::Config::Loader.new(source_path: dir)
      invalid_item = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Expected site\.toml scripts\[0\] to be a String or table/, invalid_item.message)

      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        plugins = ["projects"]

        [projects_plugin]
        scripts = "js/projects.js"
      TOML
      non_array = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(/Expected site\.toml projects_plugin\.scripts to be an array/, non_array.message)
    end
  end

  def test_build_site_rejects_non_absolute_local_asset_paths
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
        scripts = ["js/site.js"]
        styles = ["css/site.css"]
      TOML
      File.write(File.join(dir, "projects.toml"), "")

      loader = Pressa::Config::Loader.new(source_path: dir)
      error = assert_raises(Pressa::Config::ValidationError) { loader.build_site }
      assert_match(%r{start with / or use http\(s\) scheme}, error.message)
    end
  end

  def test_build_site_allows_string_home_links_and_optional_labels_for_gemini
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"

        [outputs.gemini]
        home_links = [
          "/about/",
          {"href": "/posts/"},
          {"label": "GitHub", "href": "https://github.com/samsonjs"}
        ]
      TOML
      File.write(File.join(dir, "projects.toml"), "projects = []\n")

      loader = Pressa::Config::Loader.new(source_path: dir)
      site = loader.build_site(output_format: "gemini")

      assert_equal("gemini", site.output_format)
      assert_equal(3, site.gemini_output_options&.home_links&.length)
      assert_nil(site.gemini_output_options&.home_links&.at(0)&.label)
      assert_nil(site.gemini_output_options&.home_links&.at(1)&.label)
      assert_equal("GitHub", site.gemini_output_options&.home_links&.at(2)&.label)
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
        styles = ["/css/style.css"]
        plugins = ["posts", "projects"]

        [projects_plugin]
        scripts = ["/js/projects.js"]
        styles = []

        [outputs.html]
        remote_links = [
          {"label": "Mastodon", "href": "https://techhub.social/@sjs", "icon": "mastodon"},
          {"label": "GitHub", "href": "https://github.com/samsonjs", "icon": "github"}
        ]

        [outputs.gemini]
        recent_posts_limit = 20
        home_links = ["/about/", "https://github.com/samsonjs"]
        exclude_public = ["tweets/**"]
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
