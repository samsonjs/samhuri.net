require "test_helper"
require "pressa/web/job_registry"

class Pressa::Web::JobRegistryTest < Minitest::Test
  # Runs work on the calling thread so tests never wait on a scheduler.
  def inline_executor = ->(&block) { block.call }

  # Holds the work instead of running it, so a job stays "running".
  def deferred_executor
    @deferred ||= []
    ->(&block) { @deferred << block }
  end

  def registry(executor: inline_executor, **options)
    Pressa::Web::JobRegistry.new(executor:, **options)
  end

  def test_start_runs_the_work_and_records_the_result
    subject = registry
    job = subject.start(kind: "publish_link", label: "Tree Well Protocol") do |running|
      running.append("==> Building")
      "posts/2026/06/tree-well-protocol.md"
    end

    assert_equal(:succeeded, job.state)
    assert_equal("posts/2026/06/tree-well-protocol.md", job.result)
    assert_equal(["==> Building"], job.lines)
  end

  def test_start_records_a_raised_error_as_a_failed_job
    subject = registry
    job = subject.start(kind: "publish_link") { raise "rsync exited with 23" }

    assert_equal(:failed, job.state)
    assert_equal("rsync exited with 23", job.error)
  end

  def test_a_second_start_while_one_is_running_reports_the_running_job
    subject = registry(executor: deferred_executor)
    running = subject.start(kind: "publish_link", label: "First") { "ok" }

    error = assert_raises(Pressa::Web::JobRegistry::Busy) do
      subject.start(kind: "publish_link", label: "Second") { "ok" }
    end

    assert_same(running, error.job)
    assert_equal("First", error.job.label)
  end

  def test_the_slot_frees_up_once_a_job_finishes
    subject = registry
    subject.start(kind: "publish_link") { "ok" }

    assert_nil(subject.current)
    assert(subject.start(kind: "publish_link") { "ok" })
  end

  def test_the_slot_frees_up_even_when_the_work_raises
    subject = registry
    subject.start(kind: "publish_link") { raise "boom" }

    assert_nil(subject.current)
  end

  def test_current_is_the_running_job
    subject = registry(executor: deferred_executor)
    job = subject.start(kind: "publish_link") { "ok" }

    assert_same(job, subject.current)
  end

  def test_find_looks_up_running_and_finished_jobs_by_id
    subject = registry
    job = subject.start(kind: "publish_link") { "ok" }

    assert_same(job, subject.find(job.id))
    assert_nil(subject.find("nope"))
  end

  def test_jobs_get_distinct_ids
    subject = registry
    ids = 3.times.map { subject.start(kind: "publish_link") { "ok" }.id }

    assert_equal(3, ids.uniq.length)
  end

  def test_recent_lists_newest_first_and_forgets_old_jobs
    subject = registry(max_history: 2)
    3.times { |i| subject.start(kind: "publish_link", label: "job #{i}") { "ok" } }

    assert_equal(["job 2", "job 1"], subject.recent.map(&:label))
  end
end
