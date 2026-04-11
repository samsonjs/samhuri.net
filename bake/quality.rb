require "fileutils"
require "open3"
require "tmpdir"

LINT_TARGETS = %w[bake.rb Gemfile bake lib test].freeze

# Run Minitest tests
def test
  run_test_suite(test_file_list)
end

# Run Guard for continuous testing
def guard
  exec "bundle exec guard"
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
  capture_command("ruby", "-Ilib", "-Itest", "-e", coverage_script(lowest_count:), *test_files, chdir:)
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

def standardrb_command(*extra_args)
  ["bundle", "exec", "standardrb", *extra_args, *LINT_TARGETS]
end

def run_standardrb(*extra_args)
  run_command(*standardrb_command(*extra_args))
end

def run_command(*command)
  abort "Error: command failed: #{command.join(" ")}" unless system(*command)
end
