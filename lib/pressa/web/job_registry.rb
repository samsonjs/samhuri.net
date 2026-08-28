require "monitor"
require "securerandom"
require "pressa/web/job"

module Pressa
  module Web
    # Holds the one job that may run at a time, plus a short history.
    #
    # Publishing pulls, commits, pushes, builds, and rsyncs a git checkout that
    # bin/post-link also writes to over SSH. Two of those at once would corrupt
    # something, so a second request while one is running is refused outright
    # rather than queued — silently queueing a publish is worse than being told
    # to wait.
    class JobRegistry
      class Busy < StandardError
        attr_reader :job

        def initialize(job)
          @job = job
          super("#{job.kind} job #{job.id} is already running")
        end
      end

      MAX_HISTORY = 20

      def initialize(executor: ->(&block) { Thread.new(&block) }, clock: -> { Time.now }, max_history: MAX_HISTORY)
        @executor = executor
        @clock = clock
        @max_history = max_history
        @current = nil
        @history = []
        @monitor = Monitor.new
      end

      # Claims the single work slot and starts the block on the executor,
      # returning the job right away so the request can redirect to its status
      # stream. Raises Busy, carrying the running job, when the slot is taken.
      def start(kind:, label: nil, &work)
        job = @monitor.synchronize do
          raise Busy.new(@current) if @current

          @current = Job.new(id: next_id, kind:, label:, clock: @clock)
        end

        @executor.call { run(job, &work) }
        job
      end

      def current
        @monitor.synchronize { @current }
      end

      def find(id)
        @monitor.synchronize do
          return @current if @current&.id == id

          @history.find { it.id == id }
        end
      end

      # Newest first, running job included.
      def recent
        @monitor.synchronize { [@current, *@history].compact }
      end

      private

      def run(job, &work)
        job.succeed(work.call(job))
      rescue => e
        job.fail(e.message)
      ensure
        retire(job)
      end

      def retire(job)
        @monitor.synchronize do
          @current = nil
          @history.unshift(job)
          @history.pop while @history.length > @max_history
        end
      end

      def next_id
        "#{@clock.call.strftime("%H%M%S")}-#{SecureRandom.hex(3)}"
      end
    end
  end
end
