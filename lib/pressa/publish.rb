module Pressa
  # Builds the rsync invocation used to deploy generated output to a host.
  # The bake publish tasks own the actual process spawn; this just assembles argv.
  module Publish
    module_function

    # A nil host publishes locally (no SSH), used when building on the host itself.
    def rsync_command(local_paths:, host:, publish_dir:, dry_run:, delete:)
      command = ["rsync", "-aKv"]
      command.push("-e", "ssh -4") if host
      command << "--dry-run" if dry_run
      command << "--delete" if delete
      command.concat(local_paths)
      command << (host ? "#{host}:#{publish_dir}" : publish_dir)
      command
    end
  end
end
