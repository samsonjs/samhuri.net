require "test_helper"
require "fileutils"
require "tmpdir"

class Pressa::SiteGeneratorTest < Minitest::Test
  def site
    @site ||= Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net",
      plugins: [],
      renderers: []
    )
  end

  def test_rejects_a_target_path_that_matches_the_source_path
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "public"))
      source_file = File.join(dir, "public", "keep.txt")
      File.write(source_file, "safe")

      generator = Pressa::SiteGenerator.new(site:)
      error = assert_raises(ArgumentError) do
        generator.generate(source_path: dir, target_path: dir)
      end

      assert_match(/must not be the same as or contain source_path/, error.message)
      assert_equal("safe", File.read(source_file))
    end
  end

  def test_does_not_copy_ignored_dotfiles_from_public
    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "source")
      target_path = File.join(dir, "target")
      public_path = File.join(source_path, "public")
      FileUtils.mkdir_p(public_path)

      File.write(File.join(public_path, ".DS_Store"), "finder cache")
      File.write(File.join(public_path, ".gitkeep"), "")
      File.write(File.join(public_path, "visible.txt"), "ok")

      Pressa::SiteGenerator.new(site:).generate(source_path:, target_path:)

      assert(File.exist?(File.join(target_path, "visible.txt")))
      refute(File.exist?(File.join(target_path, ".DS_Store")))
      refute(File.exist?(File.join(target_path, ".gitkeep")))
    end
  end
end
