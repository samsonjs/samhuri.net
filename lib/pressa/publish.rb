module Pressa
  # Builds the rsync invocation used to deploy generated output to a host.
  # The bake publish tasks own the actual process spawn; this just assembles argv.
  module Publish
    module_function

    # A nil host publishes locally (no SSH), used when building on the host itself.
    #
    # The publish directories carry a POSIX ACL so both sjs and the Actions
    # runner can write them, and on a file with an ACL the group bits are the
    # mask: -a alone would copy the build's 755/644 modes and clamp the other
    # account to read-only, so the group bits are forced open. Directory times
    # are left alone (-O): only the owner may set them, and each publisher
    # finds directories the other created.
    def rsync_command(local_paths:, host:, publish_dir:, dry_run:, delete:, excludes: [])
      command = ["rsync", "-aKOv", "--chmod=ug+rwX"]
      excludes.each { command << "--exclude=#{it}" }
      command.push("-e", "ssh -4") if host
      command << "--dry-run" if dry_run
      command << "--delete" if delete
      command.concat(local_paths)
      command << (host ? "#{host}:#{publish_dir}" : publish_dir)
      command
    end
  end
end
