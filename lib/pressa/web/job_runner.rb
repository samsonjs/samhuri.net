require "open3"

module Pressa
  module Web
    # Runs one of the existing publish scripts and streams its progress.
    #
    # bin/post-link already knows how to pull, write, commit, push, build, and
    # rsync; the web app runs that same script rather than a second copy of the
    # flow. The scripts follow the convention that stderr is progress and
    # stdout is the answer (the post path, the preview URL), so stderr lines
    # are streamed to the caller as they arrive and stdout becomes the result.
    module JobRunner
      class Failed < StandardError
        attr_reader :exit_status

        def initialize(message, exit_status:)
          @exit_status = exit_status
          super(message)
        end
      end

      # Yields each output line as it arrives and returns the command's stdout.
      # Reads whole lines, which suits the line-oriented scripts it runs.
      def self.run(command:, stdin_data: nil, chdir: nil, env: {}, &on_line)
        stdout_lines = []
        log_tail = nil

        options = chdir ? {chdir: chdir} : {}
        status = Open3.popen3(env, *command, **options) do |stdin, stdout, stderr, wait_thread|
          stdin.write(stdin_data) if stdin_data
          stdin.close

          open_streams = [stdout, stderr]
          until open_streams.empty?
            ready, = IO.select(open_streams)
            ready.each do |stream|
              line = stream.gets
              if line.nil?
                open_streams.delete(stream)
                next
              end

              line = line.chomp
              stdout_lines << line if stream == stdout
              log_tail = line unless line.strip.empty?
              on_line&.call(line)
            end
          end

          wait_thread.value
        end

        unless status.success?
          raise Failed.new(log_tail || "#{command.first} exited with status #{status.exitstatus}",
            exit_status: status.exitstatus)
        end

        stdout_lines.join("\n").strip
      end
    end
  end
end
