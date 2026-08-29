require "test_helper"
require "fileutils"
require "json"
require "rack/test"
require "tmpdir"
require "pressa/web/app"

class Pressa::Web::AppTest < Minitest::Test
  include Rack::Test::Methods

  POST_SOURCE = <<~MARKDOWN
    ---
    Title: Tree Well Protocol
    Author: Jane Doe
    Date: 7th June, 2026
    Timestamp: 2026-06-07T14:30:00-07:00
    Tags: snowboarding, safety
    ---

    Never ride alone in deep snow.
  MARKDOWN

  DRAFT_SOURCE = <<~MARKDOWN
    ---
    Author: Fat Mike
    Title: Lift Line Notes
    Date: unpublished
    Timestamp: 2026-06-07T14:30:00-07:00
    Tags:
    ---

    Chairlift conversations, collected.
  MARKDOWN

  def setup
    @root = Dir.mktmpdir
    FileUtils.mkdir_p(File.join(@root, "posts/2026/06"))
    FileUtils.mkdir_p(File.join(@root, "public/drafts"))
    File.write(File.join(@root, "posts/2026/06/tree-well-protocol.md"), POST_SOURCE)
    File.write(File.join(@root, "public/drafts/lift-line-notes.md"), DRAFT_SOURCE)

    @metadata = nil
    write_bin("post-link", "cat > /dev/null; echo ran >> ran.log; echo '==> Building' >&2; echo posts/2026/06/new-post.md")
    write_bin("publish-draft", "echo ran >> ran.log; echo '==> Publishing' >&2; echo \"posts/2026/06/$1.md\"")
  end

  # The app runs the repo's real scripts, so tests stand in fake ones rather
  # than injecting a command runner.
  def write_bin(name, script)
    path = File.join(@root, "bin", name)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, "#!/bin/sh\n#{script}\n")
    FileUtils.chmod(0o755, path)
  end

  # The scripts append to ran.log, so a test can assert one never ran.
  def publish_attempts
    path = File.join(@root, "ran.log")
    File.exist?(path) ? File.read(path).lines.size : 0
  end

  # Stands in for Pressa::OpenGraph.
  def scraper = self

  def fetch(_url) = @metadata

  def teardown
    FileUtils.remove_entry(@root)
  end

  def build_site(output_format)
    options = (output_format == "gemini") ? Pressa::GeminiOutputOptions.new : Pressa::HTMLOutputOptions.new
    Pressa::Site.new(
      author: "Sami Samhuri", email: "sami@samhuri.net", title: "samhuri.net",
      description: "blog", url: "https://samhuri.net", output_format:, output_options: options
    )
  end

  def app
    @app ||= Class.new(Pressa::Web::App) do
      set :environment, :test
      set :show_exceptions, false
      set :raise_errors, true
      set :host_authorization, {permitted_hosts: []}
    end.tap do |klass|
      klass.set(:repo_root, @root)
      klass.set(:html_site, build_site("html"))
      klass.set(:gemini_site, build_site("gemini"))
      klass.set(:author, "Sami Samhuri")
      klass.set(:link_scraper, scraper)
    end
  end

  def json_body = JSON.parse(last_response.body)

  # --- posting a link ------------------------------------------------------

  def test_the_home_page_is_the_link_form
    get "/"

    assert_predicate(last_response, :ok?)
    assert_includes(last_response.body, %(name="link"))
    assert_includes(last_response.body, %(name="title"))
  end

  def test_the_home_page_offers_tags_already_in_use_as_chips
    get "/"

    assert_includes(last_response.body, "snowboarding")
    assert_includes(last_response.body, "safety")
  end

  def test_posting_a_link_publishes_and_shows_the_result
    post "/link", link: "https://powder.example.net/tree-wells", title: "Tree Well Protocol",
      body: "Never ride alone.", tags: "Snowboarding, Safety"

    assert_predicate(last_response, :ok?)
    assert_includes(last_response.body, "posts/2026/06/new-post.md")
    assert_includes(last_response.body, "==&gt; Building")
    assert_equal(1, publish_attempts)
  end

  def test_a_successful_publish_clears_the_form
    post "/link", link: "https://powder.example.net/tree-wells", title: "Tree Well Protocol"

    refute_includes(last_response.body, %(value="https://powder.example.net/tree-wells"))
  end

  def test_posting_a_link_sends_the_form_to_the_script_as_json_on_stdin
    write_bin("post-link", "cat > payload.json; echo posts/x.md")
    post "/link", link: "https://powder.example.net/tree-wells", title: "Tree Well Protocol",
      body: "Never ride alone.\r\nSecond line.", tags: "Snowboarding,  safety , "

    payload = JSON.parse(File.read(File.join(@root, "payload.json")))

    assert_equal("Tree Well Protocol", payload["title"])
    assert_equal("https://powder.example.net/tree-wells", payload["link"])
    assert_equal("Never ride alone.\nSecond line.", payload["body"])
    assert_equal("snowboarding, safety", payload["tags"])
  end

  def test_a_failing_publish_shows_the_error_and_the_log
    write_bin("post-link", "echo '==> Pulling' >&2; echo 'fatal: not a git repository' >&2; exit 128")
    post "/link", link: "https://powder.example.net/x", title: "Tree Well Protocol"

    assert_equal(500, last_response.status)
    assert_includes(last_response.body, "fatal: not a git repository")
    assert_includes(last_response.body, "==&gt; Pulling")
  end

  def test_a_failing_publish_keeps_what_was_typed
    write_bin("post-link", "exit 128")
    post "/link", link: "https://powder.example.net/x", title: "Tree Well Protocol", body: "Never ride alone."

    assert_includes(last_response.body, "Never ride alone.")
  end

  # The scripts flock the checkout; exit 75 is EX_TEMPFAIL, meaning something
  # else holds it -- the phone Shortcut over SSH, most likely.
  def test_a_publish_that_cannot_get_the_lock_says_to_try_again
    write_bin("post-link", "echo 'Error: another publish is already running' >&2; exit 75")
    post "/link", link: "https://powder.example.net/x", title: "Tree Well Protocol"

    assert_equal(409, last_response.status)
    assert_includes(last_response.body, "Try again in a moment")
  end

  def test_a_link_without_a_url_or_title_is_rejected_and_the_form_comes_back_filled_in
    post "/link", link: "", title: "", body: "Never ride alone."

    assert_equal(422, last_response.status)
    assert_includes(last_response.body, "Never ride alone.")
    assert_equal(0, publish_attempts)
  end

  # --- link metadata -------------------------------------------------------

  def test_link_metadata_returns_what_the_scraper_found
    @metadata = Pressa::OpenGraph::Result.new(
      title: "Tree Wells", description: "A field guide.", image: "https://powder.example.net/cover.png"
    )
    get "/link/metadata", url: "https://powder.example.net/tree-wells"

    assert_predicate(last_response, :ok?)
    assert_equal("Tree Wells", json_body["title"])
    assert_equal("A field guide.", json_body["description"])
    assert_equal("https://powder.example.net/cover.png", json_body["image"])
  end

  def test_link_metadata_is_an_empty_object_when_the_page_offers_nothing
    get "/link/metadata", url: "https://powder.example.net/bare"

    assert_predicate(last_response, :ok?)
    assert_empty(json_body)
  end

  def test_link_metadata_needs_a_url
    get "/link/metadata"

    assert_equal(400, last_response.status)
  end

  # --- preview -------------------------------------------------------------

  def test_preview_renders_link_form_fields_as_html_and_gemtext
    post "/preview", link: "https://powder.example.net/tree-wells", title: "Tree Well Protocol",
      body: "Never ride alone.", tags: "snowboarding"

    assert_predicate(last_response, :ok?)
    assert_includes(json_body["html"], "Never ride alone.")
    assert_includes(json_body["gemtext"], "# Tree Well Protocol")
    assert_includes(json_body["gemtext"], "=> https://powder.example.net/tree-wells")
  end

  def test_preview_renders_raw_draft_source
    post "/preview", source: DRAFT_SOURCE

    assert_predicate(last_response, :ok?)
    assert_includes(json_body["gemtext"], "# Lift Line Notes")
    assert_includes(json_body["html"], "Chairlift conversations, collected.")
  end

  def test_preview_reports_bad_source_rather_than_blowing_up
    post "/preview", source: "no front matter here\n"

    assert_equal(422, last_response.status)
    assert(json_body["error"])
  end

  # --- jobs ----------------------------------------------------------------

  # --- drafts --------------------------------------------------------------

  def test_drafts_are_listed_newest_first
    get "/drafts"

    assert_predicate(last_response, :ok?)
    assert_includes(last_response.body, "Lift Line Notes")
  end

  def test_creating_a_draft_redirects_to_its_editor
    post "/drafts", title: "Tree Well Protocol"

    assert_equal(303, last_response.status)
    assert_match(%r{/drafts/tree-well-protocol\z}, last_response.headers["Location"])
    assert(File.exist?(File.join(@root, "public/drafts/tree-well-protocol.md")))
  end

  def test_creating_a_draft_that_already_exists_is_refused
    post "/drafts", title: "Lift Line Notes"

    assert_equal(409, last_response.status)
  end

  def test_creating_a_draft_with_an_unusable_title_is_refused
    post "/drafts", title: "!!!"

    assert_equal(422, last_response.status)
  end

  def test_the_editor_shows_the_draft_source
    get "/drafts/lift-line-notes"

    assert_predicate(last_response, :ok?)
    assert_includes(last_response.body, "Chairlift conversations, collected.")
  end

  def draft_path = File.join(@root, "public/drafts/lift-line-notes.md")

  def current_version
    get "/drafts/lift-line-notes"
    last_response.body[/name="version" value="([a-f0-9]+)"/, 1]
  end

  def test_the_editor_carries_a_version_of_what_it_loaded
    refute_nil(current_version)
  end

  def test_saving_a_draft_writes_it_back
    post "/drafts/lift-line-notes",
      source: "---\nTitle: Lift Line Notes\n---\n\nRewritten.\n", version: current_version

    assert_equal(303, last_response.status)
    assert_includes(File.read(draft_path), "Rewritten.")
  end

  def test_a_save_from_a_stale_editor_is_refused_and_keeps_both_versions
    stale = current_version
    File.write(draft_path, "---\nTitle: Lift Line Notes\n---\n\nThe other tab got here first.\n")

    post "/drafts/lift-line-notes", source: "My slower edit.\n", version: stale

    assert_equal(409, last_response.status)
    assert_includes(last_response.body, "My slower edit.")
    assert_includes(last_response.body, "The other tab got here first.")
    assert_includes(File.read(draft_path), "The other tab got here first.")
    refute_includes(File.read(draft_path), "My slower edit.")
  end

  def test_a_save_with_no_version_at_all_is_refused
    post "/drafts/lift-line-notes", source: "From a tab opened before the deploy.\n"

    assert_equal(422, last_response.status)
    assert_includes(last_response.body, "From a tab opened before the deploy.")
    refute_includes(File.read(draft_path), "From a tab opened before the deploy.")
  end

  def test_publishing_a_draft_runs_the_script_and_shows_the_result
    post "/drafts/lift-line-notes/publish"

    assert_predicate(last_response, :ok?)
    assert_includes(last_response.body, "posts/2026/06/lift-line-notes.md")
    assert_equal(1, publish_attempts)
  end

  def test_a_failing_draft_publish_shows_the_error
    write_bin("publish-draft", "echo 'Error: no draft' >&2; exit 1")
    post "/drafts/lift-line-notes/publish"

    assert_equal(500, last_response.status)
    assert_includes(last_response.body, "Error: no draft")
  end

  def test_deleting_a_draft_removes_it
    post "/drafts/lift-line-notes/delete"

    assert_equal(303, last_response.status)
    refute(File.exist?(File.join(@root, "public/drafts/lift-line-notes.md")))
  end

  def test_an_unknown_draft_is_a_404
    get "/drafts/nope"

    assert_equal(404, last_response.status)
  end

  def test_a_draft_slug_that_could_escape_the_drafts_directory_is_a_404
    get "/drafts/..%2F..%2Fsite"

    assert_equal(404, last_response.status)
  end

  # --- odds and ends -------------------------------------------------------

  def test_tags_are_available_as_json
    get "/tags"

    assert_predicate(last_response, :ok?)
    assert_includes(json_body, "snowboarding")
  end

  # What web/config.ru does at boot, and the only thing that builds a Site.
  def test_configure_sites_builds_both_from_the_repos_own_config
    %w[site.toml projects.toml].each do |config|
      FileUtils.cp(File.expand_path("../../#{config}", __dir__), File.join(@root, config))
    end
    app.set(:html_site, nil)
    app.set(:gemini_site, nil)
    app.set(:author, nil)
    app.configure_sites!

    post "/preview", source: DRAFT_SOURCE

    assert_predicate(last_response, :ok?)
    assert_includes(json_body["gemtext"], "# Lift Line Notes")
    assert_equal("Sami Samhuri", app.html_site.author)
  end

  def test_a_missing_site_configuration_says_where_to_set_it
    app.set(:html_site, nil)

    error = assert_raises(Pressa::Web::App::ConfigurationError) do
      post "/preview", source: DRAFT_SOURCE
    end

    assert_match(/config\.ru/, error.message)
  end

  def test_an_unknown_page_is_a_404
    get "/nowhere"

    assert_equal(404, last_response.status)
    assert_includes(last_response.body, "Not here")
  end

  def test_there_is_a_health_check
    get "/up"

    assert_predicate(last_response, :ok?)
  end

  # --- cross-origin protection ---------------------------------------------
  #
  # There are no cookies or sessions here, so the ambient credential a malicious
  # page would be riding is this machine's position on the tailnet. Sec-Fetch-*
  # are forbidden header names, so page JavaScript can't forge them.

  def sec_fetch(site) = {"HTTP_SEC_FETCH_SITE" => site}

  def test_a_cross_site_publish_is_refused
    post "/link", {link: "https://powder.example.net/x", title: "Tree Well Protocol"}, sec_fetch("cross-site")

    assert_equal(403, last_response.status)
    assert_equal(0, publish_attempts)
  end

  def test_a_same_site_publish_is_refused_too
    post "/link", {link: "https://powder.example.net/x", title: "Tree Well Protocol"}, sec_fetch("same-site")

    assert_equal(403, last_response.status)
    assert_equal(0, publish_attempts)
  end

  def test_a_same_origin_publish_goes_through
    post "/link", {link: "https://powder.example.net/x", title: "Tree Well Protocol"}, sec_fetch("same-origin")

    assert_predicate(last_response, :ok?)
  end

  def test_a_user_initiated_publish_goes_through
    post "/link", {link: "https://powder.example.net/x", title: "Tree Well Protocol"}, sec_fetch("none")

    assert_predicate(last_response, :ok?)
  end

  def test_a_request_with_no_browser_headers_goes_through
    post "/link", link: "https://powder.example.net/x", title: "Tree Well Protocol"

    assert_predicate(last_response, :ok?)
  end

  def test_an_older_browser_falls_back_to_the_origin_header
    post "/link", {link: "https://powder.example.net/x", title: "Tree Well Protocol"},
      {"HTTP_ORIGIN" => "https://evil.example.net"}

    assert_equal(403, last_response.status)
    assert_equal(0, publish_attempts)
  end

  def test_a_matching_origin_header_goes_through
    post "/link", {link: "https://powder.example.net/x", title: "Tree Well Protocol"},
      {"HTTP_ORIGIN" => "http://example.org"}

    assert_predicate(last_response, :ok?)
  end

  def test_cross_site_draft_deletion_is_refused
    post "/drafts/lift-line-notes/delete", {}, sec_fetch("cross-site")

    assert_equal(403, last_response.status)
    assert(File.exist?(File.join(@root, "public/drafts/lift-line-notes.md")))
  end

  def test_cross_site_draft_publishing_is_refused
    post "/drafts/lift-line-notes/publish", {}, sec_fetch("cross-site")

    assert_equal(403, last_response.status)
    assert_equal(0, publish_attempts)
  end

  def test_reading_pages_cross_site_is_still_allowed
    get "/", {}, sec_fetch("cross-site")

    assert_predicate(last_response, :ok?)
  end

  # The one GET that gets the same treatment: it makes this server fetch a URL
  # the caller chose, so cross-site callers could use it to probe the tailnet.
  def test_cross_site_link_metadata_is_refused
    get "/link/metadata", {url: "http://100.64.0.1:9091/"}, sec_fetch("cross-site")

    assert_equal(403, last_response.status)
  end

  def test_same_origin_link_metadata_is_allowed
    @metadata = Pressa::OpenGraph::Result.new(title: "Tree Wells", description: nil, image: nil)
    get "/link/metadata", {url: "https://powder.example.net/tree-wells"}, sec_fetch("same-origin")

    assert_predicate(last_response, :ok?)
    assert_equal("Tree Wells", json_body["title"])
  end

  def test_link_metadata_still_works_without_browser_headers
    get "/link/metadata", url: "https://powder.example.net/bare"

    assert_predicate(last_response, :ok?)
  end
end
