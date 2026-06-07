module Pressa
  # Pure helpers for the coverage tasks: the in-subprocess measurement script,
  # parsing its output, and resolving a baseline ref. The git plumbing that
  # actually computes a merge-base stays in the bake tasks that call this.
  module Coverage
    class Error < StandardError; end

    module_function

    def parse_percent(output)
      match = output.match(/Coverage \(lib\):\s+([0-9]+\.[0-9]+)%/)
      raise Error, "unable to parse coverage output." unless match

      Float(match[1])
    end

    # Resolve a baseline ref. Yields (and returns the block's value) only when
    # the baseline is "merge-base", so the git work is deferred to the caller.
    def resolve_baseline_ref(baseline)
      name = baseline.to_s.strip
      raise Error, "baseline cannot be empty." if name.empty?

      return yield if name == "merge-base"

      name
    end

    def script(lowest_count:)
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
  end
end
