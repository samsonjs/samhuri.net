require "fileutils"

WATCHABLE_DIRECTORIES = %w[public posts lib].freeze
BUILD_TARGETS = %w[debug mudge beta release gemini].freeze

# Generate the site in debug mode (localhost:8000)
def debug
  build("http://localhost:8000", output_format: "html", target_path: "www")
end

# Generate the site for the mudge development server
def mudge
  build("http://mudge:8000", output_format: "html", target_path: "www")
end

# Generate the site for beta/staging
def beta
  build("https://beta.samhuri.net", output_format: "html", target_path: "www")
end

# Generate the site for production
def release
  build("https://samhuri.net", output_format: "html", target_path: "www")
end

# Generate the Gemini capsule for production
def gemini
  build("https://samhuri.net", output_format: "gemini", target_path: "gemini")
end

# Start local development server
def serve
  require "webrick"
  server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: "www")
  trap("INT") { server.shutdown }
  puts "Server running at http://localhost:8000"
  server.start
end

# Clean generated files
def clean
  FileUtils.rm_rf("www")
  FileUtils.rm_rf("gemini")
  puts "Cleaned www/ and gemini/ directories"
end

# Watch content directories and rebuild on every change.
# @parameter target [String] One of debug, mudge, beta, release, or gemini.
def watch(target: "debug")
  unless command_available?("inotifywait")
    abort "inotifywait is required (install inotify-tools)."
  end

  loop do
    abort "Error: watch failed." unless system("inotifywait", "-e", "modify,create,delete,move", *watch_paths)
    puts "changed at #{Time.now}"
    sleep 2
    run_build_target(target)
  end
end

private

# Build the site with specified URL and output format.
# @parameter url [String] The site URL to use.
# @parameter output_format [String] One of html or gemini.
# @parameter target_path [String] Target directory for generated output.
def build(url, output_format:, target_path:)
  require "pressa"

  puts "Building #{output_format} site for #{url}..."
  site = Pressa.create_site(source_path: ".", url_override: url, output_format:)
  generator = Pressa::SiteGenerator.new(site:)
  generator.generate(source_path: ".", target_path:)
  puts "Site built successfully in #{target_path}/"
end

def run_build_target(target)
  target_name = target.to_s
  unless BUILD_TARGETS.include?(target_name)
    abort "Error: invalid target '#{target_name}'. Use one of: #{BUILD_TARGETS.join(", ")}"
  end

  public_send(target_name)
end

def watch_paths
  WATCHABLE_DIRECTORIES.flat_map { |path| ["-r", path] }
end

def command_available?(command)
  system("which", command, out: File::NULL, err: File::NULL)
end
