# Build tasks for samhuri.net static site generator

require "etc"
require "fileutils"
require "open3"
require "tmpdir"

DRAFTS_DIR = "public/drafts".freeze
PUBLISH_HOST = "mudge".freeze
PRODUCTION_PUBLISH_DIR = "/var/www/samhuri.net/public".freeze
BETA_PUBLISH_DIR = "/var/www/beta.samhuri.net/public".freeze
WATCHABLE_DIRECTORIES = %w[public posts lib].freeze
LINT_TARGETS = %w[bake.rb Gemfile lib spec].freeze
BUILD_TARGETS = %w[debug mudge beta release].freeze

# Generate the site in debug mode (localhost:8000)
def debug
  build("http://localhost:8000")
end

# Generate the site for the mudge development server
def mudge
  build("http://mudge:8000")
end

# Generate the site for beta/staging
def beta
  build("https://beta.samhuri.net")
end

# Generate the site for production
def release
  build("https://samhuri.net")
end

# Start local development server
def serve
  require "webrick"
  server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: "www")
  trap("INT") { server.shutdown }
  puts "Server running at http://localhost:8000"
  server.start
end

# Create a new draft in public/drafts/.
# @parameter title_parts [Array] Optional title words; defaults to Untitled.
def new_draft(*title_parts)
  title, filename =
    if title_parts.empty?
      ["Untitled", next_available_draft]
    else
      given_title = title_parts.join(" ")
      slug = slugify(given_title)
      abort "Error: title cannot be converted to a filename." if slug.empty?

      filename = "#{slug}.md"
      path = draft_path(filename)
      abort "Error: draft already exists at #{path}" if File.exist?(path)

      [given_title, filename]
    end

  FileUtils.mkdir_p(DRAFTS_DIR)
  path = draft_path(filename)
  content = render_draft_template(title)
  File.write(path, content)

  puts "Created new draft at #{path}"
  puts ">>> Contents below <<<"
  puts
  puts content
end

# Publish a draft by moving it to posts/YYYY/MM and updating dates.
# @parameter input_path [String] Draft path or filename in public/drafts.
def publish_draft(input_path = nil)
  if input_path.nil? || input_path.strip.empty?
    puts "Usage: bake publish_draft <draft-path-or-filename>"
    puts
    puts "Available drafts:"
    drafts = Dir.glob("#{DRAFTS_DIR}/*.md").map { |path| File.basename(path) }
    if drafts.empty?
      puts "  (no drafts found)"
    else
      drafts.each { |draft| puts "  #{draft}" }
    end
    abort
  end

  draft_path_value, draft_file = resolve_draft_input(input_path)
  abort "Error: File not found: #{draft_path_value}" unless File.exist?(draft_path_value)

  now = Time.now
  content = File.read(draft_path_value)
  content.sub!(/^Date:.*$/, "Date: #{ordinal_date(now)}")
  content.sub!(/^Timestamp:.*$/, "Timestamp: #{now.strftime("%Y-%m-%dT%H:%M:%S%:z")}")

  target_dir = "posts/#{now.strftime("%Y/%m")}"
  FileUtils.mkdir_p(target_dir)
  target_path = "#{target_dir}/#{draft_file}"

  File.write(target_path, content)
  FileUtils.rm_f(draft_path_value)

  puts "Published draft: #{draft_path_value} -> #{target_path}"
end

# Watch content directories and rebuild on every change.
# @parameter target [String] One of debug, mudge, beta, or release.
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

# Publish to production server
def publish
  release
  run_rsync(local_paths: ["www/"], publish_dir: PRODUCTION_PUBLISH_DIR, dry_run: false, delete: true)
end

# Clean generated files
def clean
  FileUtils.rm_rf("www")
  puts "Cleaned www/ directory"
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

  baseline_ref = resolve_coverage_baseline_ref(baseline)
  baseline_commit = capture_command("git", "rev-parse", "--short", baseline_ref).strip

  puts "Running coverage for current checkout..."
  current_output = capture_coverage_output(test_files: test_file_list, lowest_count:, chdir: Dir.pwd)
  print current_output
  current_percent = parse_coverage_percent(current_output)

  puts "Running coverage for baseline #{baseline_ref} (#{baseline_commit})..."
  baseline_percent = with_temporary_worktree(ref: baseline_ref) do |worktree_path|
    baseline_tests = test_file_list(chdir: worktree_path)
    baseline_output = capture_coverage_output(test_files: baseline_tests, lowest_count: 0, chdir: worktree_path)
    parse_coverage_percent(baseline_output)
  end

  delta = current_percent - baseline_percent
  puts format("Baseline coverage (%s %s): %.2f%%", baseline_ref, baseline_commit, baseline_percent)
  puts format("Coverage delta: %+0.2f%%", delta)

  return unless delta.negative?

  abort format("Error: coverage regressed by %.2f%% against %s (%s).", -delta, baseline_ref, baseline_commit)
end

private

def run_test_suite(test_files)
  run_command("ruby", "-Ilib", "-Ispec", "-e", "ARGV.each { |file| require File.expand_path(file) }", *test_files)
end

def run_coverage(test_files:, lowest_count:)
  output = capture_coverage_output(test_files:, lowest_count:, chdir: Dir.pwd)
  print output
end

def test_file_list(chdir: Dir.pwd)
  test_files = Dir.chdir(chdir) { Dir.glob("spec/**/*_test.rb").sort }
  abort "Error: no tests found in spec/**/*_test.rb under #{chdir}" if test_files.empty?

  test_files
end

def coverage_script(lowest_count:)
  <<~RUBY
    require "coverage"

    root = Dir.pwd
    lib_root = File.join(root, "lib") + "/"
    Coverage.start(lines: true)

    at_exit do
      result = Coverage.result
      rows = result.keys
        .select { |file| file.start_with?(lib_root) && file.end_with?(".rb") }
        .sort
        .map do |file|
          lines = result[file][:lines] || []
          total = 0
          covered = 0
          lines.each do |line_count|
            next if line_count.nil?
            total += 1
            covered += 1 if line_count.positive?
          end
          percent = total.zero? ? 100.0 : (covered.to_f / total * 100)
          [file, covered, total, percent]
        end

      covered_lines = rows.sum { |row| row[1] }
      total_lines = rows.sum { |row| row[2] }
      overall_percent = total_lines.zero? ? 100.0 : (covered_lines.to_f / total_lines * 100)
      puts format("Coverage (lib): %.2f%% (%d / %d lines)", overall_percent, covered_lines, total_lines)

      unless #{lowest_count}.zero? || rows.empty?
        puts "Lowest covered files:"
        rows.sort_by { |row| row[3] }.first(#{lowest_count}).each do |file, covered, total, percent|
          relative_path = file.delete_prefix(root + "/")
          puts format("  %6.2f%% %d/%d %s", percent, covered, total, relative_path)
        end
      end
    end

    ARGV.each { |file| require File.expand_path(file) }
  RUBY
end

def capture_coverage_output(test_files:, lowest_count:, chdir:)
  capture_command("ruby", "-Ilib", "-Ispec", "-e", coverage_script(lowest_count:), *test_files, chdir:)
end

def parse_coverage_percent(output)
  match = output.match(/Coverage \(lib\):\s+([0-9]+\.[0-9]+)%/)
  abort "Error: unable to parse coverage output." unless match

  Float(match[1])
end

def resolve_coverage_baseline_ref(baseline)
  baseline_name = baseline.to_s.strip
  abort "Error: baseline cannot be empty." if baseline_name.empty?

  return coverage_merge_base_ref if baseline_name == "merge-base"

  baseline_name
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
  return upstream_remote if upstream_remote && !upstream_remote.empty?

  remotes = capture_command("git", "remote").lines.map(&:strip).reject(&:empty?)
  abort "Error: no git remotes configured; pass baseline=<ref>." if remotes.empty?

  remotes.include?("origin") ? "origin" : remotes.first
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

# Build the site with specified URL
# @parameter url [String] The site URL to use
def build(url)
  require_relative "lib/pressa"

  puts "Building site for #{url}..."
  site = Pressa.create_site(source_path: ".", url_override: url)
  generator = Pressa::SiteGenerator.new(site:)
  generator.generate(source_path: ".", target_path: "www")
  puts "Site built successfully in www/"
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
  command = ["rsync", "-aKv", "-e", "ssh -4"]
  command << "--dry-run" if dry_run
  command << "--delete" if delete
  command.concat(local_paths)
  command << "#{PUBLISH_HOST}:#{publish_dir}"
  abort "Error: rsync failed." unless system(*command)
end

def resolve_draft_input(input_path)
  if input_path.include?("/")
    if input_path.start_with?("posts/")
      abort "Error: '#{input_path}' is already published in posts/ directory"
    end

    [input_path, File.basename(input_path)]
  else
    [draft_path(input_path), input_path]
  end
end

def draft_path(filename)
  File.join(DRAFTS_DIR, filename)
end

def slugify(title)
  title.downcase
    .gsub(/[^a-z0-9\s-]/, "")
    .gsub(/\s+/, "-").squeeze("-")
    .gsub(/^-|-$/, "")
end

def next_available_draft(base_filename = "untitled.md")
  return base_filename unless File.exist?(draft_path(base_filename))

  name_without_ext = File.basename(base_filename, ".md")
  counter = 1
  loop do
    numbered_filename = "#{name_without_ext}-#{counter}.md"
    return numbered_filename unless File.exist?(draft_path(numbered_filename))

    counter += 1
  end
end

def render_draft_template(title)
  now = Time.now
  <<~FRONTMATTER
    ---
    Author: #{current_author}
    Title: #{title}
    Date: unpublished
    Timestamp: #{now.strftime("%Y-%m-%dT%H:%M:%S%:z")}
    Tags:
    ---

    # #{title}

    TKTK
  FRONTMATTER
end

def current_author
  Etc.getlogin || ENV["USER"] || `whoami`.strip
rescue
  ENV["USER"] || `whoami`.strip
end

def ordinal_date(time)
  day = time.day
  suffix = case day
  when 1, 21, 31
    "st"
  when 2, 22
    "nd"
  when 3, 23
    "rd"
  else
    "th"
  end

  time.strftime("#{day}#{suffix} %B, %Y")
end

def command_available?(command)
  system("which", command, out: File::NULL, err: File::NULL)
end
