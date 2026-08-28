require "test_helper"
require "pressa/web/job"

class Pressa::Web::JobTest < Minitest::Test
  def job(**overrides)
    defaults = {id: "abc123", kind: "publish_link", label: "Tree Well Protocol"}
    Pressa::Web::Job.new(**defaults.merge(overrides))
  end

  def test_starts_out_running_with_no_lines
    entry = job

    assert_predicate(entry, :running?)
    refute_predicate(entry, :finished?)
    assert_empty(entry.lines)
    assert_nil(entry.result)
    assert_nil(entry.finished_at)
  end

  def test_append_collects_lines_in_order
    entry = job
    entry.append("==> Pulling latest")
    entry.append("==> Creating link post")

    assert_equal(["==> Pulling latest", "==> Creating link post"], entry.lines)
  end

  def test_lines_returns_a_snapshot_that_cannot_mutate_the_job
    entry = job
    entry.append("one")
    entry.lines << "two"

    assert_equal(["one"], entry.lines)
  end

  def test_succeed_records_the_result_and_finishes
    entry = job
    entry.succeed("posts/2026/06/tree-well-protocol.md")

    assert_predicate(entry, :finished?)
    refute_predicate(entry, :running?)
    assert_equal(:succeeded, entry.state)
    assert_equal("posts/2026/06/tree-well-protocol.md", entry.result)
    assert(entry.finished_at)
  end

  def test_fail_records_the_error_and_finishes
    entry = job
    entry.fail("rsync exited with 23")

    assert_predicate(entry, :finished?)
    assert_equal(:failed, entry.state)
    assert_equal("rsync exited with 23", entry.error)
  end

  def test_subscribe_hands_back_the_backlog_and_then_live_lines
    entry = job
    entry.append("==> Pulling latest")

    backlog, queue = entry.subscribe
    entry.append("==> Building")

    assert_equal(["==> Pulling latest"], backlog)
    assert_equal("==> Building", queue.pop)
  end

  def test_subscribers_are_woken_when_the_job_finishes
    entry = job
    _backlog, queue = entry.subscribe
    entry.succeed("done")

    assert_nil(queue.pop)
  end

  def test_subscribing_to_a_finished_job_yields_the_backlog_and_an_immediate_end
    entry = job
    entry.append("==> Building")
    entry.succeed("done")

    backlog, queue = entry.subscribe

    assert_equal(["==> Building"], backlog)
    assert_nil(queue.pop)
  end

  def test_unsubscribe_stops_delivery
    entry = job
    _backlog, queue = entry.subscribe
    entry.unsubscribe(queue)
    entry.append("==> Building")

    assert_predicate(queue, :empty?)
  end

  def test_to_h_carries_what_the_status_stream_needs
    entry = job
    entry.append("==> Building")
    entry.succeed("posts/2026/06/tree-well-protocol.md")

    payload = entry.to_h

    assert_equal("abc123", payload[:id])
    assert_equal("publish_link", payload[:kind])
    assert_equal("Tree Well Protocol", payload[:label])
    assert_equal("succeeded", payload[:state])
    assert_equal("posts/2026/06/tree-well-protocol.md", payload[:result])
    assert_nil(payload[:error])
  end

  def test_append_ignores_lines_once_the_job_has_finished
    entry = job
    entry.succeed("done")
    entry.append("too late")

    assert_empty(entry.lines)
  end
end
