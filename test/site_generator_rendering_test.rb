require "test_helper"
require "fileutils"
require "tmpdir"

class Pressa::SiteGeneratorRenderingTest < Minitest::Test
  class PluginSpy
    attr_reader :calls

    def initialize
      @calls = []
    end

    def setup(site:, source_path:)
      @calls << [:setup, site.title, source_path]
    end

    def render(site:, target_path:)
      @calls << [:render, site.title, target_path]
      File.write(File.join(target_path, "plugin-output.txt"), "plugin rendered")
    end
  end

  class PostsPluginSpy < PluginSpy
    attr_reader :posts_by_year, :render_site_year

    def initialize(posts_by_year:)
      super()
      @posts_by_year = posts_by_year
    end

    def render(site:, target_path:)
      @render_site_year = site.copyright_start_year
      super
    end
  end

  class MarkdownRendererSpy
    attr_reader :calls

    def initialize
      @calls = []
    end

    def can_render_file?(filename:, extension:)
      extension == "md" && !filename.start_with?("_")
    end

    def render(site:, file_path:, target_dir:)
      @calls << [site.title, file_path, target_dir]
      FileUtils.mkdir_p(target_dir)
      slug = File.basename(file_path, ".md")
      File.write(File.join(target_dir, "#{slug}.html"), "rendered #{slug}")
    end
  end

  def build_site(plugin:, renderer:)
    Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net",
      plugins: [plugin],
      renderers: [renderer]
    )
  end

  def build_posts_by_year(year:)
    post = Pressa::Posts::Post.new(
      slug: "first-post",
      title: "First Post",
      author: "Sami Samhuri",
      date: DateTime.parse("#{year}-02-01T10:00:00-08:00"),
      formatted_date: "1st February, #{year}",
      body: "<p>First post</p>",
      excerpt: "First post...",
      path: "/posts/#{year}/02/first-post"
    )

    month_posts = Pressa::Posts::MonthPosts.new(
      month: Pressa::Posts::Month.new(name: "February", number: 2, padded: "02"),
      posts: [post]
    )

    year_posts = Pressa::Posts::YearPosts.new(year:, by_month: {2 => month_posts})
    Pressa::Posts::PostsByYear.new(by_year: {year => year_posts})
  end

  def test_generate_runs_plugins_copies_static_files_and_renders_supported_files
    Dir.mktmpdir do |root|
      source_path = File.join(root, "source")
      target_path = File.join(root, "target")
      public_dir = File.join(source_path, "public", "nested")
      FileUtils.mkdir_p(public_dir)

      File.write(File.join(source_path, "public", "plain.txt"), "copy me")
      File.write(File.join(source_path, "public", "home.md"), "# home")
      File.write(File.join(source_path, "public", ".hidden"), "skip me")
      File.write(File.join(public_dir, "page.md"), "# title")
      File.write(File.join(public_dir, "_ignore.md"), "# ignored")

      plugin = PluginSpy.new
      renderer = MarkdownRendererSpy.new
      site = build_site(plugin:, renderer:)

      Pressa::SiteGenerator.new(site:).generate(source_path:, target_path:)

      assert_equal(2, plugin.calls.length)
      assert_equal(:setup, plugin.calls[0][0])
      assert_equal(:render, plugin.calls[1][0])
      assert_equal("samhuri.net", renderer.calls.first[0])
      assert(renderer.calls.any? do |call|
        call[1].end_with?("/public/nested/page.md") &&
          File.expand_path(call[2]) == File.expand_path(File.join(target_path, "nested"))
      end)
      assert(renderer.calls.any? do |call|
        call[1].end_with?("/public/home.md") &&
          File.expand_path(call[2]) == File.expand_path(target_path)
      end)

      assert(File.exist?(File.join(target_path, "plain.txt")))
      assert_equal("copy me", File.read(File.join(target_path, "plain.txt")))
      refute(File.exist?(File.join(target_path, ".hidden")))
      refute(File.exist?(File.join(target_path, "nested", "page.md")))
      assert(File.exist?(File.join(target_path, "home.html")))
      assert(File.exist?(File.join(target_path, "nested", "page.html")))
      refute(File.exist?(File.join(target_path, "nested", "_ignore.html")))
      assert(File.exist?(File.join(target_path, "plugin-output.txt")))
    end
  end

  def test_generate_handles_missing_public_directory
    Dir.mktmpdir do |root|
      source_path = File.join(root, "source")
      target_path = File.join(root, "target")
      FileUtils.mkdir_p(source_path)

      plugin = PluginSpy.new
      renderer = MarkdownRendererSpy.new
      site = build_site(plugin:, renderer:)

      Pressa::SiteGenerator.new(site:).generate(source_path:, target_path:)

      assert(File.exist?(File.join(target_path, "plugin-output.txt")))
      assert_empty(renderer.calls)
    end
  end

  def test_generate_sets_copyright_start_year_from_earliest_post_year
    Dir.mktmpdir do |root|
      source_path = File.join(root, "source")
      target_path = File.join(root, "target")
      FileUtils.mkdir_p(source_path)

      plugin = PostsPluginSpy.new(posts_by_year: build_posts_by_year(year: 2006))
      renderer = MarkdownRendererSpy.new
      site = build_site(plugin:, renderer:)

      Pressa::SiteGenerator.new(site:).generate(source_path:, target_path:)

      assert_equal(2006, plugin.render_site_year)
    end
  end
end
