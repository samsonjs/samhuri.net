require "spec_helper"
require "fileutils"
require "tmpdir"

RSpec.describe Pressa::SiteGenerator do
  let(:site) do
    Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net",
      plugins: [],
      renderers: []
    )
  end

  it "rejects a target path that matches the source path" do
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "public"))
      source_file = File.join(dir, "public", "keep.txt")
      File.write(source_file, "safe")

      generator = described_class.new(site:)

      expect {
        generator.generate(source_path: dir, target_path: dir)
      }.to raise_error(ArgumentError, /must not be the same as or contain source_path/)

      expect(File.read(source_file)).to eq("safe")
    end
  end

  it "does not copy ignored dotfiles from public" do
    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "source")
      target_path = File.join(dir, "target")
      public_path = File.join(source_path, "public")
      FileUtils.mkdir_p(public_path)

      File.write(File.join(public_path, ".DS_Store"), "finder cache")
      File.write(File.join(public_path, ".gitkeep"), "")
      File.write(File.join(public_path, "visible.txt"), "ok")

      described_class.new(site:).generate(source_path:, target_path:)

      expect(File.exist?(File.join(target_path, "visible.txt"))).to be(true)
      expect(File.exist?(File.join(target_path, ".DS_Store"))).to be(false)
      expect(File.exist?(File.join(target_path, ".gitkeep"))).to be(false)
    end
  end
end
