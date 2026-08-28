require "monitor"
require "time"

module Pressa
  module Web
    # One unit of long-running work — publishing a link, publishing a draft —
    # with its log. Publishing mutates a git checkout and takes far too long
    # for a blocking request, so requests start a job and then watch it.
    #
    # Written by the worker thread and read by every connected browser, so all
    # state changes go through the monitor. Subscribers get the backlog and a
    # live queue in one atomic step, which is what lets a phone reconnect
    # mid-publish without missing or repeating lines.
    class Job
      STATES = %i[running succeeded failed].freeze

      attr_reader :id, :kind, :label, :started_at, :finished_at, :state, :result, :error

      def initialize(id:, kind:, label: nil, clock: -> { Time.now })
        @id = id
        @kind = kind
        @label = label
        @clock = clock
        @state = :running
        @started_at = clock.call
        @finished_at = nil
        @result = nil
        @error = nil
        @lines = []
        @subscribers = []
        @monitor = Monitor.new
      end

      def running? = state == :running

      def finished? = !running?

      def lines
        @monitor.synchronize { @lines.dup }
      end

      def append(line)
        @monitor.synchronize do
          return if finished?

          @lines << line
          @subscribers.each { it << line }
        end
      end

      def succeed(result)
        finish(:succeeded) { @result = result }
      end

      def fail(error)
        finish(:failed) { @error = error }
      end

      # Returns the lines so far plus a queue carrying every line after them,
      # then nil once the job finishes. Taken together under the monitor so no
      # line can slip between the snapshot and the subscription.
      def subscribe
        @monitor.synchronize do
          queue = Queue.new
          if finished?
            queue << nil
          else
            @subscribers << queue
          end
          [@lines.dup, queue]
        end
      end

      def unsubscribe(queue)
        @monitor.synchronize { @subscribers.delete(queue) }
      end

      def duration
        return nil unless finished_at

        finished_at - started_at
      end

      def to_h
        @monitor.synchronize do
          {
            id: @id,
            kind: @kind,
            label: @label,
            state: @state.to_s,
            started_at: @started_at.iso8601,
            finished_at: @finished_at&.iso8601,
            duration: duration,
            result: @result,
            error: @error
          }
        end
      end

      private

      def finish(state)
        @monitor.synchronize do
          return if finished?

          yield
          @state = state
          @finished_at = @clock.call
          @subscribers.each { it << nil }
          @subscribers.clear
        end
      end
    end
  end
end
