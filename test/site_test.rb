require "test_helper"
require "tmpdir"

class Pressa::SiteTest < Minitest::Test
  def test_url_helpers
    site = Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net",
      image_url: "https://images.example.net"
    )

    assert_equal("https://samhuri.net/posts", site.url_for("/posts"))
    assert_equal("https://images.example.net/avatar.png", site.image_url_for("/avatar.png"))
  end

  def test_image_url_for_returns_nil_when_image_url_not_configured
    site = Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net"
    )

    assert_nil(site.image_url_for("/avatar.png"))
  end

  def test_create_site_builds_site_using_loader
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "site.toml"), <<~TOML)
        author = "Sami Samhuri"
        email = "sami@samhuri.net"
        title = "samhuri.net"
        description = "blog"
        url = "https://samhuri.net"
      TOML
      File.write(File.join(dir, "projects.toml"), <<~TOML)
        [[projects]]
        name = "demo"
        title = "demo"
        description = "demo project"
        url = "https://github.com/samsonjs/demo"
      TOML

      site = Pressa.create_site(source_path: dir, url_override: "https://beta.samhuri.net")
      assert_equal("https://beta.samhuri.net", site.url)
    end
  end
end
