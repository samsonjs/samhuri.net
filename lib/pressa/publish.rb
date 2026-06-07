module Pressa
  # Builds the rsync invocation used to deploy generated output to a host.
  # The bake publish tasks own the actual process spawn; this just assembles argv.
  module Publish
    module_function

    def rsync_command(local_paths:, host:, publish_dir:, dry_run:, delete:)
      command = ["rsync", "-aKv", "-e", "ssh -4"]
      command << "--dry-run" if dry_run
      command << "--delete" if delete
      command.concat(local_paths)
      command << "#{host}:#{publish_dir}"
      command
    end
  end
end
