# Build tasks for samhuri.net static site generator

require "etc"
require "fileutils"

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

# Default task: run tests and lint.
def default
  test
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

private

def run_test_suite(test_files)
  run_command("ruby", "-Ilib", "-Ispec", "-e", "ARGV.each { |file| require File.expand_path(file) }", *test_files)
end

def run_coverage(test_files:, lowest_count:)
  coverage_script = <<~RUBY
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

  run_command("ruby", "-Ilib", "-Ispec", "-e", coverage_script, *test_files)
end

def test_file_list
  test_files = Dir.glob("spec/**/*_test.rb").sort
  abort "Error: no tests found in spec/**/*_test.rb" if test_files.empty?

  test_files
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
