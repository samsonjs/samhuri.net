require "test_helper"
require "tmpdir"
require "pressa/web/job_runner"

class Pressa::Web::JobRunnerTest < Minitest::Test
  def sh(script) = ["sh", "-c", script]

  def test_returns_stdout_as_the_result
    result = Pressa::Web::JobRunner.run(command: sh("echo posts/2026/06/tree-well-protocol.md"))

    assert_equal("posts/2026/06/tree-well-protocol.md", result)
  end

  def test_streams_progress_lines_to_the_block_as_they_arrive
    lines = []
    Pressa::Web::JobRunner.run(command: sh("echo '==> Pulling' >&2; echo '==> Building' >&2")) do |line|
      lines << line
    end

    assert_equal(["==> Pulling", "==> Building"], lines)
  end

  def test_the_log_carries_stdout_too_so_nothing_is_hidden
    lines = []
    Pressa::Web::JobRunner.run(command: sh("echo progress >&2; echo the-result")) { lines << it }

    assert_equal(["progress", "the-result"], lines.sort)
  end

  def test_sends_stdin_data_to_the_process
    result = Pressa::Web::JobRunner.run(command: sh("cat"), stdin_data: %({"title":"Ride On"}))

    assert_equal(%({"title":"Ride On"}), result)
  end

  def test_runs_in_the_given_directory
    Dir.mktmpdir do |tmpdir|
      result = Pressa::Web::JobRunner.run(command: sh("pwd"), chdir: tmpdir)

      assert_equal(File.realpath(tmpdir), File.realpath(result))
    end
  end

  def test_passes_environment_variables_through
    result = Pressa::Web::JobRunner.run(
      command: sh("echo $SAMHURI_PUBLISH_HOST"), env: {"SAMHURI_PUBLISH_HOST" => "local"}
    )

    assert_equal("local", result)
  end

  def test_raises_with_the_last_log_line_when_the_command_fails
    error = assert_raises(Pressa::Web::JobRunner::Failed) do
      Pressa::Web::JobRunner.run(command: sh("echo 'fatal: not a git repository' >&2; exit 128"))
    end

    assert_equal("fatal: not a git repository", error.message)
    assert_equal(128, error.exit_status)
  end

  def test_raises_with_the_exit_status_when_the_command_says_nothing
    error = assert_raises(Pressa::Web::JobRunner::Failed) do
      Pressa::Web::JobRunner.run(command: sh("exit 23"))
    end

    assert_match(/exited with status 23/, error.message)
  end

  def test_streams_lines_before_the_command_finishes
    seen_early = false
    Pressa::Web::JobRunner.run(command: sh("echo first >&2; sleep 0.2; echo second >&2")) do |line|
      seen_early = true if line == "first"
      raise "second arrived before first was streamed" if line == "second" && !seen_early
    end

    assert(seen_early)
  end
end
