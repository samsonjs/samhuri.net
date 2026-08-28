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
    @executor = ->(&block) { block.call }
    write_bin("post-link", "cat > /dev/null; echo '==> Building' >&2; echo posts/2026/06/new-post.md")
    write_bin("publish-draft", "echo '==> Publishing' >&2; echo \"posts/2026/06/$1.md\"")
  end

  # The app runs the repo's real scripts, so tests stand in fake ones rather
  # than injecting a command runner.
  def write_bin(name, script)
    path = File.join(@root, "bin", name)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, "#!/bin/sh\n#{script}\n")
    FileUtils.chmod(0o755, path)
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

  def registry
    @registry ||= Pressa::Web::JobRegistry.new(executor: ->(&block) { @executor.call(&block) })
  end

  def app
    @app ||= Class.new(Pressa::Web::App) do
      set :environment, :test
      set :show_exceptions, false
      set :raise_errors, true
      set :host_authorization, {permitted_hosts: []}
    end.tap do |klass|
      klass.set(:repo_root, @root)
      klass.set(:registry, registry)
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

  def test_posting_a_link_starts_a_job_and_redirects_to_it
    post "/link", link: "https://powder.example.net/tree-wells", title: "Tree Well Protocol",
      body: "Never ride alone.", tags: "Snowboarding, Safety"

    assert_equal(303, last_response.status)
    job = registry.recent.first
    assert_match(%r{/jobs/#{job.id}\z}, last_response.headers["Location"])
    assert_equal("posts/2026/06/new-post.md", job.result)
    assert_equal("publish_link", job.kind)
  end

  def test_posting_a_link_sends_the_form_to_the_script_as_json_on_stdin
    write_bin("post-link", "cat; echo; echo posts/x.md")
    post "/link", link: "https://powder.example.net/tree-wells", title: "Tree Well Protocol",
      body: "Never ride alone.\r\nSecond line.", tags: "Snowboarding,  safety , "

    payload = JSON.parse(registry.recent.first.lines.first)

    assert_equal("Tree Well Protocol", payload["title"])
    assert_equal("https://powder.example.net/tree-wells", payload["link"])
    assert_equal("Never ride alone.\nSecond line.", payload["body"])
    assert_equal("snowboarding, safety", payload["tags"])
  end

  def test_a_failing_publish_leaves_a_failed_job_rather_than_a_500
    write_bin("post-link", "echo 'fatal: not a git repository' >&2; exit 128")
    post "/link", link: "https://powder.example.net/x", title: "Tree Well Protocol"

    assert_equal(303, last_response.status)
    assert_equal(:failed, registry.recent.first.state)
    assert_equal("fatal: not a git repository", registry.recent.first.error)
  end

  def test_a_second_publish_while_one_is_running_is_refused_not_queued
    held = nil
    @executor = ->(&block) { held = block }
    post "/link", link: "https://powder.example.net/one", title: "First Post"
    post "/link", link: "https://powder.example.net/two", title: "Second Post"

    assert_equal(409, last_response.status)
    assert_includes(last_response.body, "already")
    assert_equal(1, registry.recent.length)
    refute_nil(held)
  end

  def test_a_link_without_a_url_or_title_is_rejected_and_the_form_comes_back_filled_in
    post "/link", link: "", title: "", body: "Never ride alone."

    assert_equal(422, last_response.status)
    assert_includes(last_response.body, "Never ride alone.")
    assert_empty(registry.recent)
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

  def test_a_job_page_shows_its_state_and_log
    post "/link", link: "https://powder.example.net/x", title: "Tree Well Protocol"
    job = registry.recent.first
    get "/jobs/#{job.id}"

    assert_predicate(last_response, :ok?)
    assert_includes(last_response.body, "==&gt; Building")
    assert_includes(last_response.body, "posts/2026/06/new-post.md")
  end

  def test_an_unknown_job_is_a_404
    get "/jobs/nope"

    assert_equal(404, last_response.status)
  end

  def test_the_job_stream_replays_the_log_and_ends_with_the_final_state
    post "/link", link: "https://powder.example.net/x", title: "Tree Well Protocol"
    job = registry.recent.first
    get "/jobs/#{job.id}/stream"

    assert_match(%r{\Atext/event-stream}, last_response.headers["Content-Type"])
    events = last_response.body.scan(/^data: (.+)$/).flatten.map { JSON.parse(it) }

    assert_includes(events.map { it["text"] }, "==> Building")
    assert_equal("succeeded", events.last["state"])
  end

  def test_the_job_stream_delivers_lines_while_the_job_is_still_running
    @executor = ->(&block) { Thread.new(&block) }
    app.set(:keep_alive_seconds, 0.05)
    write_bin("post-link", "echo '==> Pulling' >&2; sleep 0.5; echo '==> Building' >&2; echo posts/x.md")
    post "/link", link: "https://powder.example.net/x", title: "Tree Well Protocol"
    job = registry.recent.first

    get "/jobs/#{job.id}/stream"
    events = last_response.body.scan(/^data: (.+)$/).flatten.map { JSON.parse(it) }

    assert_includes(events.map { it["text"] }, "==> Building")
    assert_includes(last_response.body, ": keep-alive")
    assert_equal("succeeded", events.last["state"])
  end

  def test_streaming_an_unknown_job_is_a_404
    get "/jobs/nope/stream"

    assert_equal(404, last_response.status)
  end

  def test_the_jobs_page_lists_recent_jobs
    post "/link", link: "https://powder.example.net/x", title: "Tree Well Protocol"
    get "/jobs"

    assert_predicate(last_response, :ok?)
    assert_includes(last_response.body, "Tree Well Protocol")
  end

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

  def test_saving_a_draft_writes_it_back
    post "/drafts/lift-line-notes", source: "---\nTitle: Lift Line Notes\n---\n\nRewritten.\n"

    assert_equal(303, last_response.status)
    assert_includes(File.read(File.join(@root, "public/drafts/lift-line-notes.md")), "Rewritten.")
  end

  def test_publishing_a_draft_starts_a_job
    post "/drafts/lift-line-notes/publish"

    assert_equal(303, last_response.status)
    job = registry.recent.first

    assert_equal("publish_draft", job.kind)
    assert_equal("posts/2026/06/lift-line-notes.md", job.result)
  end

  def test_publishing_a_draft_while_something_is_running_is_refused
    held = nil
    @executor = ->(&block) { held = block }
    post "/link", link: "https://powder.example.net/one", title: "First Post"
    post "/drafts/lift-line-notes/publish"

    assert_equal(409, last_response.status)
    assert_includes(last_response.body, "already")
    assert_equal(1, registry.recent.length)
    refute_nil(held)
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

  def test_the_site_config_comes_from_the_repo_when_it_is_not_supplied
    %w[site.toml projects.toml].each do |config|
      FileUtils.cp(File.expand_path("../../#{config}", __dir__), File.join(@root, config))
    end
    app.set(:html_site, nil)
    app.set(:gemini_site, nil)
    app.set(:author, nil)

    post "/preview", source: DRAFT_SOURCE

    assert_predicate(last_response, :ok?)
    assert_includes(json_body["gemtext"], "# Lift Line Notes")
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
    assert_empty(registry.recent)
  end

  def test_a_same_site_publish_is_refused_too
    post "/link", {link: "https://powder.example.net/x", title: "Tree Well Protocol"}, sec_fetch("same-site")

    assert_equal(403, last_response.status)
    assert_empty(registry.recent)
  end

  def test_a_same_origin_publish_goes_through
    post "/link", {link: "https://powder.example.net/x", title: "Tree Well Protocol"}, sec_fetch("same-origin")

    assert_equal(303, last_response.status)
  end

  def test_a_user_initiated_publish_goes_through
    post "/link", {link: "https://powder.example.net/x", title: "Tree Well Protocol"}, sec_fetch("none")

    assert_equal(303, last_response.status)
  end

  def test_a_request_with_no_browser_headers_goes_through
    post "/link", link: "https://powder.example.net/x", title: "Tree Well Protocol"

    assert_equal(303, last_response.status)
  end

  def test_an_older_browser_falls_back_to_the_origin_header
    post "/link", {link: "https://powder.example.net/x", title: "Tree Well Protocol"},
      {"HTTP_ORIGIN" => "https://evil.example.net"}

    assert_equal(403, last_response.status)
    assert_empty(registry.recent)
  end

  def test_a_matching_origin_header_goes_through
    post "/link", {link: "https://powder.example.net/x", title: "Tree Well Protocol"},
      {"HTTP_ORIGIN" => "http://example.org"}

    assert_equal(303, last_response.status)
  end

  def test_cross_site_draft_deletion_is_refused
    post "/drafts/lift-line-notes/delete", {}, sec_fetch("cross-site")

    assert_equal(403, last_response.status)
    assert(File.exist?(File.join(@root, "public/drafts/lift-line-notes.md")))
  end

  def test_cross_site_draft_publishing_is_refused
    post "/drafts/lift-line-notes/publish", {}, sec_fetch("cross-site")

    assert_equal(403, last_response.status)
    assert_empty(registry.recent)
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
