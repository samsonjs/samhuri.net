# Build tasks for Pressa static site generator

# Generate the site in debug mode (localhost:8000)
def debug
  build('http://localhost:8000')
end

# Generate the site for the mudge development server
def mudge
  build('http://mudge:8000')
end

# Generate the site for beta/staging
def beta
  build('https://beta.samhuri.net')
end

# Generate the site for production
def release
  build('https://samhuri.net')
end

# Start local development server
def serve
  require 'webrick'
  server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: 'www')
  trap('INT') { server.shutdown }
  puts "Server running at http://localhost:8000"
  server.start
end

# Publish to beta/staging server
def publish_beta
  beta
  puts "Deploying to beta server..."
  system('rsync -avz --delete www/ mudge:/var/www/beta.samhuri.net/public')
end

# Publish to production server
def publish
  release
  puts "Deploying to production server..."
  system('rsync -avz --delete www/ mudge:/var/www/samhuri.net/public')
end

# Clean generated files
def clean
  require 'fileutils'
  FileUtils.rm_rf('www')
  puts "Cleaned www/ directory"
end

# Run RSpec tests
def test
  exec 'bundle exec rspec'
end

# Run Guard for continuous testing
def guard
  exec 'bundle exec guard'
end

# List all available drafts
def drafts
  Dir.glob('drafts/*.md').sort.each do |draft|
    puts File.basename(draft)
  end
end

# Run StandardRB linter
def lint
  exec 'bundle exec standardrb'
end

# Auto-fix StandardRB issues
def lint_fix
  exec 'bundle exec standardrb --fix'
end

private

# Build the site with specified URL
# @parameter url [String] The site URL to use
def build(url)
  require_relative 'lib/pressa'

  puts "Building site for #{url}..."
  site = Pressa.create_site(url_override: url)
  generator = Pressa::SiteGenerator.new(site:)
  generator.generate(source_path: '..', target_path: 'www')
  puts "Site built successfully in www/"
end
