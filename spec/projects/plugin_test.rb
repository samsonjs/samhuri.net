require "test_helper"
require "tmpdir"

class Pressa::Projects::PluginTest < Minitest::Test
  def site
    @site ||= Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net"
    )
  end

  def project
    @project ||= Pressa::Projects::Project.new(
      name: "demo",
      title: "Demo",
      description: "Demo project",
      url: "https://github.com/samsonjs/demo"
    )
  end

  def test_setup_is_a_no_op
    plugin = Pressa::Projects::Plugin.new(projects: [project])
    assert_nil(plugin.setup(site:, source_path: "/tmp/unused"))
  end

  def test_render_writes_projects_index_and_project_page
    plugin = Pressa::Projects::Plugin.new(
      projects: [project],
      scripts: [Pressa::Script.new(src: "js/projects.js", defer: false)],
      styles: [Pressa::Stylesheet.new(href: "css/projects.css")]
    )

    Dir.mktmpdir do |dir|
      plugin.render(site:, target_path: dir)

      index_path = File.join(dir, "projects/index.html")
      project_path = File.join(dir, "projects/demo/index.html")

      assert(File.exist?(index_path))
      assert(File.exist?(project_path))

      index_html = File.read(index_path)
      details_html = File.read(project_path)

      assert_includes(index_html, "Projects")
      assert_includes(index_html, "Demo")
      assert_includes(details_html, "Demo project")
      assert_includes(details_html, "js/projects.js")
      assert_includes(details_html, "css/projects.css")
    end
  end
end
