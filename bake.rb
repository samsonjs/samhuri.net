# Build tasks for samhuri.net static site generator

require "fileutils"
require "json"
require "open3"
require "socket"
require "tmpdir"

LIB_PATH = File.expand_path("lib", __dir__).freeze
$LOAD_PATH.unshift(LIB_PATH) unless $LOAD_PATH.include?(LIB_PATH)

require "pressa/drafts"
require "pressa/link_post"
require "pressa/open_graph"
require "pressa/config/simple_toml"
require "pressa/coverage"
require "pressa/publish"
require "pressa/git"

DRAFTS_DIR = "public/drafts".freeze
# Defaults to the "mudge" tailnet host. A nil host means rsync into the publish
# dirs locally instead of over SSH, which is what we want when building on the
# publish host itself (otherwise we'd SSH back to ourselves). We auto-detect that
# by hostname; SAMHURI_PUBLISH_HOST=local (or empty) forces it, and any other
# value overrides the target host entirely.
PUBLISH_HOST =
  case (host = ENV.fetch("SAMHURI_PUBLISH_HOST", "mudge"))
  when "", "local" then nil
  else (host == Socket.gethostname.split(".").first) ? nil : host.freeze
  end
PRODUCTION_PUBLISH_DIR = "/var/www/samhuri.net/public".freeze
BETA_PUBLISH_DIR = "/var/www/beta.samhuri.net/public".freeze
GEMINI_PUBLISH_DIR = "/var/gemini/samhuri.net".freeze
WATCHABLE_DIRECTORIES = %w[public posts lib].freeze
LINT_TARGETS = %w[bake.rb Gemfile lib test].freeze
BUILD_TARGETS = %w[debug mudge beta release gemini].freeze

# Generate the site in debug mode (localhost:8000)
def debug
  build("http://localhost:8000", output_format: "html", target_path: "www")
end

# Generate the site for the mudge development server
def mudge
  build("http://mudge:8000", output_format: "html", target_path: "www")
end

# Generate the site for beta/staging
def beta
  build("https://beta.samhuri.net", output_format: "html", target_path: "www")
end

# Generate the site for production
def release
  build("https://samhuri.net", output_format: "html", target_path: "www")
end

# Generate the Gemini capsule for production
def gemini
  build("https://samhuri.net", output_format: "gemini", target_path: "gemini")
end

# Start local development server
def serve
  require "webrick"
  server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: "www")
  trap("INT") { server.shutdown }
  puts "Server running at http://localhost:8000"
  server.start
end

# Create a published link post in posts/YYYY/MM from a JSON payload on stdin:
#   {"title": "...", "link": "...", "body": "...", "tags": "tag1, tag2"}
# Reading from stdin keeps URLs, quotes, and multi-line bodies intact regardless
# of shell quoting. Prints the path to the created post. Drives bin/post-link.
def new_link
  payload =
    begin
      JSON.parse($stdin.read)
    rescue JSON::ParserError => e
      abort "Error: invalid JSON payload on stdin: #{e.message}"
    end

  author = payload["author"] || Pressa::Config::SimpleToml.load_file("site.toml")["author"]
  image = payload["image"] || fetch_link_image(payload["link"])
  post =
    begin
      Pressa::LinkPost.build(
        title: payload["title"],
        link: payload["link"],
        body: payload["body"],
        tags: payload["tags"],
        image:,
        author:
      )
    rescue Pressa::LinkPost::Error => e
      abort "Error: #{e.message}"
    end

  abort "Error: post already exists at #{post.target_path}" if File.exist?(post.target_path)

  FileUtils.mkdir_p(File.dirname(post.target_path))
  File.write(post.target_path, post.content)
  puts post.target_path
end

# Build a link post and preview it on the mudge blog server without touching
# git: writes posts/YYYY/MM/slug.md, builds for http://mudge:8000 (the same
# target blog-server.service serves straight out of www/), prints the
# preview URL, then deletes the local file. Drives bin/preview-link.
def preview_link
  payload =
    begin
      JSON.parse($stdin.read)
    rescue JSON::ParserError => e
      abort "Error: invalid JSON payload on stdin: #{e.message}"
    end

  author = payload["author"] || Pressa::Config::SimpleToml.load_file("site.toml")["author"]
  image = payload["image"] || fetch_link_image(payload["link"])
  post =
    begin
      Pressa::LinkPost.build(
        title: payload["title"],
        link: payload["link"],
        body: payload["body"],
        tags: payload["tags"],
        image:,
        author:
      )
    rescue Pressa::LinkPost::Error => e
      abort "Error: #{e.message}"
    end

  abort "Error: post already exists at #{post.target_path}" if File.exist?(post.target_path)

  FileUtils.mkdir_p(File.dirname(post.target_path))
  File.write(post.target_path, post.content)

  year_month = post.target_path[%r{^posts/(\d{4}/\d{2})/}, 1]
  slug = File.basename(post.filename, ".md")

  begin
    mudge
  ensure
    FileUtils.rm_f(post.target_path)
  end

  puts "http://mudge:8000/posts/#{year_month}/#{slug}/"
end

# Create a new draft in public/drafts/.
# @parameter title_parts [Array] Optional title words; defaults to Untitled.
def new_draft(*title_parts)
  drafts = Pressa::Drafts.new(dir: DRAFTS_DIR)
  title, filename =
    if title_parts.empty?
      ["Untitled", drafts.next_available]
    else
      given_title = title_parts.join(" ")
      slug = Pressa::Drafts.slugify(given_title)
      abort "Error: title cannot be converted to a filename." if slug.empty?

      filename = "#{slug}.md"
      path = drafts.path(filename)
      abort "Error: draft already exists at #{path}" if File.exist?(path)

      [given_title, filename]
    end

  FileUtils.mkdir_p(DRAFTS_DIR)
  path = drafts.path(filename)
  content = drafts.render_template(title)
  File.write(path, content)

  puts "Created new draft at #{path}"
  puts ">>> Contents below <<<"
  puts
  puts content
end

# Publish a draft by moving it to posts/YYYY/MM and updating dates.
# @parameter input_path [String] Draft path or filename in public/drafts.
def publish_draft(input_path = nil)
  drafts = Pressa::Drafts.new(dir: DRAFTS_DIR)
  if input_path.nil? || input_path.strip.empty?
    puts "Usage: bake publish_draft <draft-path-or-filename>"
    puts
    puts "Available drafts:"
    available = Dir.glob("#{DRAFTS_DIR}/*.md").map { |path| File.basename(path) }
    if available.empty?
      puts "  (no drafts found)"
    else
      available.each { |draft| puts "  #{draft}" }
    end
    abort
  end

  draft_path_value, draft_file =
    begin
      drafts.resolve_input(input_path)
    rescue Pressa::Drafts::Error => e
      abort "Error: #{e.message}"
    end
  abort "Error: File not found: #{draft_path_value}" unless File.exist?(draft_path_value)

  now = Time.now
  content = File.read(draft_path_value)
  content.sub!(/^Date:.*$/, "Date: #{Pressa::Drafts.ordinal_date(now)}")
  content.sub!(/^Timestamp:.*$/, "Timestamp: #{now.strftime("%Y-%m-%dT%H:%M:%S%:z")}")

  target_dir = "posts/#{now.strftime("%Y/%m")}"
  FileUtils.mkdir_p(target_dir)
  target_path = "#{target_dir}/#{draft_file}"

  File.write(target_path, content)
  FileUtils.rm_f(draft_path_value)

  puts "Published draft: #{draft_path_value} -> #{target_path}"
end

# Watch content directories and rebuild on every change.
# @parameter target [String] One of debug, mudge, beta, release, or gemini.
def watch(target: "debug")
  unless command_available?("inotifywait")
    abort "inotifywait is required (install inotify-tools)."
  end

  loop do
    abort "Error: watch failed." unless system("inotifywait", "-e", "modify,create,delete,move", *watch_paths)
    puts "changed at #{Time.now}"
    sleep 2
    run_build_target(target)
  end
end

# Publish to beta/staging server
def publish_beta
  beta
  run_rsync(local_paths: ["www/"], publish_dir: BETA_PUBLISH_DIR, dry_run: false, delete: true)
end

# Publish Gemini capsule to production
def publish_gemini
  gemini
  run_rsync(local_paths: ["gemini/"], publish_dir: GEMINI_PUBLISH_DIR, dry_run: false, delete: true)
end

# Publish to production server
def publish
  release
  run_rsync(local_paths: ["www/"], publish_dir: PRODUCTION_PUBLISH_DIR, dry_run: false, delete: true)
  publish_gemini
end

# Clean generated files
def clean
  FileUtils.rm_rf("www")
  FileUtils.rm_rf("gemini")
  puts "Cleaned www/ and gemini/ directories"
end

# Default task: run coverage and lint.
def default
  coverage
  lint
end

# Run Minitest tests
def test
  run_test_suite(test_file_list)
end

# Run Guard for continuous testing
def guard
  exec "bundle exec guard"
end

# List all available drafts
def drafts
  Dir.glob("#{DRAFTS_DIR}/*.md").sort.each do |draft|
    puts File.basename(draft)
  end
end

# Print tag post counts and a per-year sparkline of tag usage across posts/.
def tags
  require "pressa/posts/repo"
  require "pressa/posts/tag_report"

  posts_by_year = Pressa::Posts::PostRepo.new.read_posts("posts")
  puts Pressa::Posts::TagReport.from_posts_by_year(posts_by_year)
end

# Run StandardRB linter
def lint
  run_standardrb
end

# Auto-fix StandardRB issues
def lint_fix
  run_standardrb("--fix")
end

# Measure line coverage for files under lib/.
# @parameter lowest [Integer] Number of lowest-covered files to print (default: 10, use 0 to hide).
def coverage(lowest: 10)
  lowest_count = Integer(lowest)
  abort "Error: lowest must be >= 0." if lowest_count.negative?

  run_coverage(test_files: test_file_list, lowest_count:)
end

# Compare line coverage for files under lib/ against a baseline and fail on regression.
# @parameter baseline [String] Baseline ref, or "merge-base" (default) to compare against merge-base with remote default branch.
# @parameter lowest [Integer] Number of lowest-covered files to print for the current checkout (default: 10, use 0 to hide).
def coverage_regression(baseline: "merge-base", lowest: 10)
  lowest_count = Integer(lowest)
  abort "Error: lowest must be >= 0." if lowest_count.negative?

  baseline_ref = Pressa::Coverage.resolve_baseline_ref(baseline) { coverage_merge_base_ref }
  baseline_commit = capture_command("git", "rev-parse", "--short", baseline_ref).strip

  puts "Running coverage for current checkout..."
  current_output = capture_coverage_output(test_files: test_file_list, lowest_count:, chdir: Dir.pwd)
  print current_output
  current_percent = Pressa::Coverage.parse_percent(current_output)

  puts "Running coverage for baseline #{baseline_ref} (#{baseline_commit})..."
  baseline_percent = with_temporary_worktree(ref: baseline_ref) do |worktree_path|
    baseline_tests = test_file_list(chdir: worktree_path)
    baseline_output = capture_coverage_output(test_files: baseline_tests, lowest_count: 0, chdir: worktree_path)
    Pressa::Coverage.parse_percent(baseline_output)
  end

  delta = current_percent - baseline_percent
  puts format("Baseline coverage (%s %s): %.2f%%", baseline_ref, baseline_commit, baseline_percent)
  puts format("Coverage delta: %+0.2f%%", delta)

  return unless delta.negative?

  abort format("Error: coverage regressed by %.2f%% against %s (%s).", -delta, baseline_ref, baseline_commit)
end

private

# Best-effort: a slow or broken link shouldn't block creating the post, it
# just means the Image front-matter field is left for the author to fill in.
def fetch_link_image(link)
  return nil if link.to_s.strip.empty?

  Pressa::OpenGraph.fetch(link)&.image
end

def run_test_suite(test_files)
  run_command("ruby", "-Ilib", "-Itest", "-e", "ARGV.each { |file| require File.expand_path(file) }", *test_files)
end

def run_coverage(test_files:, lowest_count:)
  output = capture_coverage_output(test_files:, lowest_count:, chdir: Dir.pwd)
  print output
end

def test_file_list(chdir: Dir.pwd)
  test_files = Dir.chdir(chdir) { Dir.glob("test/**/*_test.rb").sort }
  abort "Error: no tests found in test/**/*_test.rb under #{chdir}" if test_files.empty?

  test_files
end

def capture_coverage_output(test_files:, lowest_count:, chdir:)
  capture_command("ruby", "-Ilib", "-Itest", "-e", Pressa::Coverage.script(lowest_count:), *test_files, chdir:)
end

def coverage_merge_base_ref
  remote = preferred_remote
  remote_head_ref = remote_default_branch_ref(remote)
  merge_base = capture_command("git", "merge-base", "HEAD", remote_head_ref).strip
  abort "Error: could not resolve merge-base with #{remote_head_ref}." if merge_base.empty?

  merge_base
end

def preferred_remote
  upstream = capture_command_optional("git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}").strip
  upstream_remote = upstream.split("/").first unless upstream.empty?
  remotes = capture_command("git", "remote").lines.map(&:strip).reject(&:empty?)

  Pressa::Git.choose_remote(remotes:, upstream_remote:)
rescue Pressa::Git::Error => e
  abort "Error: #{e.message}"
end

def remote_default_branch_ref(remote)
  symbolic = capture_command_optional("git", "symbolic-ref", "--quiet", "refs/remotes/#{remote}/HEAD").strip
  if symbolic.empty?
    fallback = "#{remote}/main"
    capture_command("git", "rev-parse", "--verify", fallback)
    return fallback
  end

  symbolic.sub("refs/remotes/", "")
end

def with_temporary_worktree(ref:)
  temp_root = Dir.mktmpdir("coverage-baseline-")
  worktree_path = File.join(temp_root, "worktree")

  run_command("git", "worktree", "add", "--detach", worktree_path, ref)
  begin
    yield worktree_path
  ensure
    system("git", "worktree", "remove", "--force", worktree_path)
    FileUtils.rm_rf(temp_root)
  end
end

def capture_command(*command, chdir: Dir.pwd)
  stdout, stderr, status = Dir.chdir(chdir) { Open3.capture3(*command) }
  output = +""
  output << stdout unless stdout.empty?
  output << stderr unless stderr.empty?
  abort "Error: command failed: #{command.join(" ")}\n#{output}" unless status.success?

  output
end

def capture_command_optional(*command, chdir: Dir.pwd)
  stdout, stderr, status = Dir.chdir(chdir) { Open3.capture3(*command) }
  return stdout if status.success?
  return "" if stderr.include?("no upstream configured") || stderr.include?("is not a symbolic ref")

  ""
end

# Build the site with specified URL and output format.
# @parameter url [String] The site URL to use.
# @parameter output_format [String] One of html or gemini.
# @parameter target_path [String] Target directory for generated output.
def build(url, output_format:, target_path:)
  require "pressa"

  puts "Building #{output_format} site for #{url}..."
  site = Pressa.create_site(source_path: ".", url_override: url, output_format:)
  generator = Pressa::SiteGenerator.new(site:)
  generator.generate(source_path: ".", target_path:)
  puts "Site built successfully in #{target_path}/"
end

def run_build_target(target)
  target_name = target.to_s
  unless BUILD_TARGETS.include?(target_name)
    abort "Error: invalid target '#{target_name}'. Use one of: #{BUILD_TARGETS.join(", ")}"
  end

  public_send(target_name)
end

def watch_paths
  WATCHABLE_DIRECTORIES.flat_map { |path| ["-r", path] }
end

def standardrb_command(*extra_args)
  ["bundle", "exec", "standardrb", *extra_args, *LINT_TARGETS]
end

def run_standardrb(*extra_args)
  run_command(*standardrb_command(*extra_args))
end

def run_command(*command)
  abort "Error: command failed: #{command.join(" ")}" unless system(*command)
end

def run_rsync(local_paths:, publish_dir:, dry_run:, delete:)
  command = Pressa::Publish.rsync_command(
    local_paths:, host: PUBLISH_HOST, publish_dir:, dry_run:, delete:
  )
  abort "Error: rsync failed." unless system(*command)
end

def command_available?(command)
  system("which", command, out: File::NULL, err: File::NULL)
end
