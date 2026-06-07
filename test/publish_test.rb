require "test_helper"

class Pressa::PublishTest < Minitest::Test
  def test_rsync_command_builds_the_base_invocation
    command = Pressa::Publish.rsync_command(
      local_paths: ["www/"], host: "mudge", publish_dir: "/var/www/samhuri.net/public",
      dry_run: false, delete: false
    )
    assert_equal(
      ["rsync", "-aKv", "-e", "ssh -4", "www/", "mudge:/var/www/samhuri.net/public"],
      command
    )
  end

  def test_rsync_command_adds_dry_run_and_delete_flags
    command = Pressa::Publish.rsync_command(
      local_paths: ["gemini/"], host: "mudge", publish_dir: "/var/gemini/samhuri.net",
      dry_run: true, delete: true
    )
    assert_includes(command, "--dry-run")
    assert_includes(command, "--delete")
  end

  def test_rsync_command_omits_flags_when_disabled
    command = Pressa::Publish.rsync_command(
      local_paths: ["www/"], host: "mudge", publish_dir: "/tmp/site",
      dry_run: false, delete: false
    )
    refute_includes(command, "--dry-run")
    refute_includes(command, "--delete")
  end

  def test_rsync_command_supports_multiple_local_paths
    command = Pressa::Publish.rsync_command(
      local_paths: ["www/", "extra/"], host: "powder", publish_dir: "/srv/site",
      dry_run: false, delete: true
    )
    assert_equal("powder:/srv/site", command.last)
    assert_includes(command, "www/")
    assert_includes(command, "extra/")
  end
end
