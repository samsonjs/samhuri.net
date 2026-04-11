PUBLISH_HOST = "mudge".freeze
PRODUCTION_PUBLISH_DIR = "/var/www/samhuri.net/public".freeze
BETA_PUBLISH_DIR = "/var/www/beta.samhuri.net/public".freeze
GEMINI_PUBLISH_DIR = "/var/gemini/samhuri.net".freeze

# Publish to beta/staging server
def beta
  call("build:beta")
  run_rsync(local_paths: ["www/"], publish_dir: BETA_PUBLISH_DIR, dry_run: false, delete: true)
end

# Publish Gemini capsule to production
def gemini
  call("build:gemini")
  run_rsync(local_paths: ["gemini/"], publish_dir: GEMINI_PUBLISH_DIR, dry_run: false, delete: true)
end

# Publish to production server
def production
  call("build:release")
  run_rsync(local_paths: ["www/"], publish_dir: PRODUCTION_PUBLISH_DIR, dry_run: false, delete: true)
  call("publish:gemini")
end

private

def run_rsync(local_paths:, publish_dir:, dry_run:, delete:)
  command = ["rsync", "-aKv", "-e", "ssh -4"]
  command << "--dry-run" if dry_run
  command << "--delete" if delete
  command.concat(local_paths)
  command << "#{PUBLISH_HOST}:#{publish_dir}"
  abort "Error: rsync failed." unless system(*command)
end
