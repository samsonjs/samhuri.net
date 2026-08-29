require "test_helper"
require "fileutils"
require "open3"
require "tmpdir"

# The publish scripts are what the phone Shortcut runs over SSH and what the
# web app spawns, and they're the part of this repo that git bugs hide in: a
# `git diff` that called untracked drafts clean once made publishing a newly
# created draft fail every time, and nothing in the Ruby suite could see it.
#
# So these run the real scripts against a real repo with a real remote. Only
# bake is stubbed, since its tasks are unit tested on their own.
class PublishScriptsTest < Minitest::Test
  SOURCE_REPO = File.expand_path("../..", __dir__)

  STUB_BAKE = <<~RUBY_SOURCE
    require "fileutils"

    def new_link
      File.write("last-payload.json", $stdin.read)
      path = "posts/2026/08/stub-link.md"
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, "a link post\\n")
      puts path
    end

    def publish_draft(input_path)
      name = File.basename(input_path)
      path = File.join("posts/2026/08", name)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, File.read(input_path))
      FileUtils.rm_f(input_path)
      warn "Published draft: \#{input_path} -> \#{path}"
      puts path
    end

    def publish
      File.write("published.marker", "deployed")
      warn "Site built successfully"
    end
  RUBY_SOURCE

  # Building the repo and its remote costs more than running the scripts, so
  # it's built once and copied per test rather than rebuilt each time.
  def self.template
    @template ||= begin
      root = Dir.mktmpdir("pressa-scripts-template")
      at_exit { FileUtils.remove_entry(root) rescue nil } # rubocop:disable Style/RescueModifier
      remote = File.join(root, "remote.git")
      work = File.join(root, "work")
      git = ->(*args, chdir: work) do
        out, status = Open3.capture2e("git", *args, chdir:)
        raise "git #{args.join(" ")} failed: #{out}" unless status.success?
      end

      git.call("init", "-q", "--bare", remote, chdir: root)
      git.call("clone", "-q", remote, work, chdir: root)
      git.call("config", "user.email", "sami@example.net")
      git.call("config", "user.name", "Sami Samhuri")

      FileUtils.cp_r(File.join(SOURCE_REPO, "bin"), work)
      %w[Gemfile Gemfile.lock .ruby-version].each { FileUtils.cp(File.join(SOURCE_REPO, it), work) }
      File.write(File.join(work, "bake.rb"), STUB_BAKE)
      FileUtils.mkdir_p(File.join(work, "public/drafts"))
      FileUtils.mkdir_p(File.join(work, "posts"))

      File.write(File.join(work, "README.md"), "seed\n")
      git.call("add", "-A")
      git.call("commit", "-qm", "seed")
      git.call("branch", "-M", "main")
      git.call("push", "-q", "origin", "main")
      root
    end
  end

  def setup
    skip "git is required" unless system("git", "--version", out: File::NULL, err: File::NULL)

    @root = Dir.mktmpdir
    FileUtils.cp_r(File.join(self.class.template, "."), @root)
    @remote = File.join(@root, "remote.git")
    @work = File.join(@root, "work")
    # The clone records an absolute path to the remote it came from.
    git!("remote", "set-url", "origin", @remote)
  end

  def teardown
    FileUtils.remove_entry(@root) if @root
  end

  def git!(*args, chdir: @work)
    out, status = Open3.capture2e("git", *args, chdir:)
    raise "git #{args.join(" ")} failed: #{out}" unless status.success?
    out
  end

  def run_script(name, *args, stdin: "")
    Open3.capture3(
      {"SAMHURI_REPO" => @work}, File.join(@work, "bin", name), *args,
      stdin_data: stdin, chdir: @work
    )
  end

  def write_draft(slug, title: "Tree Well Protocol", body: "Never ride alone.")
    File.write(File.join(@work, "public/drafts/#{slug}.md"), <<~MARKDOWN)
      ---
      Author: Jane Doe
      Title: #{title}
      Date: unpublished
      Timestamp: 2026-06-01T09:00:00-07:00
      ---

      #{body}
    MARKDOWN
  end

  def commit_subjects = git!("log", "--format=%s").lines.map(&:chomp)

  def pushed_subjects = git!("--git-dir", @remote, "log", "--format=%s", "main", chdir: @root).lines.map(&:chomp)

  # --- post-link ------------------------------------------------------------

  def test_post_link_writes_commits_pushes_and_deploys
    payload = %({"title":"Tree Well Protocol","link":"https://powder.example.net/x"})
    stdout, _stderr, status = run_script("post-link", stdin: payload)

    assert_predicate(status, :success?)
    assert_equal("posts/2026/08/stub-link.md", stdout.strip)
    assert_equal(payload, File.read(File.join(@work, "last-payload.json")))
    assert_includes(commit_subjects, "Add link post: stub-link")
    assert_includes(pushed_subjects, "Add link post: stub-link")
    assert(File.exist?(File.join(@work, "published.marker")), "should have run bake publish")
  end

  def test_post_link_refuses_an_empty_payload
    _stdout, stderr, status = run_script("post-link", stdin: "   \n")

    refute_predicate(status, :success?)
    assert_match(/empty payload/, stderr)
    assert_equal(["seed"], commit_subjects)
  end

  # --- publish-draft --------------------------------------------------------

  def test_publish_draft_commits_an_untracked_draft_before_publishing_it
    write_draft("tree-well-protocol")
    stdout, _stderr, status = run_script("publish-draft", "tree-well-protocol")

    assert_predicate(status, :success?)
    assert_equal("posts/2026/08/tree-well-protocol.md", stdout.strip)
    assert_includes(commit_subjects, "Update draft: tree-well-protocol")
    assert_includes(commit_subjects, "Publish draft: tree-well-protocol")
    assert_includes(pushed_subjects, "Publish draft: tree-well-protocol")
    refute(File.exist?(File.join(@work, "public/drafts/tree-well-protocol.md")))
  end

  def test_publish_draft_leaves_other_drafts_uncommitted
    write_draft("other-draft", title: "Other")
    git!("add", "public/drafts/other-draft.md")
    git!("commit", "-qm", "add other draft")
    File.write(File.join(@work, "public/drafts/other-draft.md"), "half-finished edit\n")

    write_draft("tree-well-protocol")
    _stdout, _stderr, status = run_script("publish-draft", "tree-well-protocol")

    assert_predicate(status, :success?)
    assert_equal("half-finished edit\n", File.read(File.join(@work, "public/drafts/other-draft.md")))
    refute_empty(git!("status", "--porcelain", "--", "public/drafts/other-draft.md"))
  end

  def test_publish_draft_accepts_a_filename_as_well_as_a_slug
    write_draft("tree-well-protocol")
    _stdout, _stderr, status = run_script("publish-draft", "tree-well-protocol.md")

    assert_predicate(status, :success?)
  end

  def test_publish_draft_refuses_a_draft_that_is_not_there
    _stdout, stderr, status = run_script("publish-draft", "nope")

    refute_predicate(status, :success?)
    assert_match(%r{no draft at public/drafts/nope\.md}, stderr)
  end

  def test_publish_draft_needs_an_argument
    _stdout, stderr, status = run_script("publish-draft")

    refute_predicate(status, :success?)
    assert_match(/Usage:/, stderr)
  end
end
