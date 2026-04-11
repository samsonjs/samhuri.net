require "etc"
require "fileutils"

DRAFTS_DIR = "public/drafts".freeze

# Create a new draft in public/drafts/.
# @parameter title_parts [Array] Optional title words; defaults to Untitled.
def new(*title_parts)
  title, filename =
    if title_parts.empty?
      ["Untitled", next_available_draft]
    else
      given_title = title_parts.join(" ")
      slug = slugify(given_title)
      abort "Error: title cannot be converted to a filename." if slug.empty?

      filename = "#{slug}.md"
      path = draft_path(filename)
      abort "Error: draft already exists at #{path}" if File.exist?(path)

      [given_title, filename]
    end

  FileUtils.mkdir_p(DRAFTS_DIR)
  path = draft_path(filename)
  content = render_draft_template(title)
  File.write(path, content)

  puts "Created new draft at #{path}"
  puts ">>> Contents below <<<"
  puts
  puts content
end

# Publish a draft by moving it to posts/YYYY/MM and updating dates.
# @parameter input_path [String] Draft path or filename in public/drafts.
def publish(input_path = nil)
  if input_path.nil? || input_path.strip.empty?
    puts "Usage: bake draft:publish <draft-path-or-filename>"
    puts
    puts "Available drafts:"
    drafts = Dir.glob("#{DRAFTS_DIR}/*.md").map { |path| File.basename(path) }
    if drafts.empty?
      puts "  (no drafts found)"
    else
      drafts.each { |draft| puts "  #{draft}" }
    end
    abort
  end

  draft_path_value, draft_file = resolve_draft_input(input_path)
  abort "Error: File not found: #{draft_path_value}" unless File.exist?(draft_path_value)

  now = Time.now
  content = File.read(draft_path_value)
  content.sub!(/^Date:.*$/, "Date: #{ordinal_date(now)}")
  content.sub!(/^Timestamp:.*$/, "Timestamp: #{now.strftime("%Y-%m-%dT%H:%M:%S%:z")}")

  target_dir = "posts/#{now.strftime("%Y/%m")}"
  FileUtils.mkdir_p(target_dir)
  target_path = "#{target_dir}/#{draft_file}"

  File.write(target_path, content)
  FileUtils.rm_f(draft_path_value)

  puts "Published draft: #{draft_path_value} -> #{target_path}"
end

# List all available drafts
def list
  Dir.glob("#{DRAFTS_DIR}/*.md").sort.each do |draft|
    puts File.basename(draft)
  end
  nil
end

private

def resolve_draft_input(input_path)
  if input_path.include?("/")
    if input_path.start_with?("posts/")
      abort "Error: '#{input_path}' is already published in posts/ directory"
    end

    [input_path, File.basename(input_path)]
  else
    [draft_path(input_path), input_path]
  end
end

def draft_path(filename)
  File.join(DRAFTS_DIR, filename)
end

def slugify(title)
  title.downcase
    .gsub(/[^a-z0-9\s-]/, "")
    .gsub(/\s+/, "-").squeeze("-")
    .gsub(/^-|-$/, "")
end

def next_available_draft(base_filename = "untitled.md")
  return base_filename unless File.exist?(draft_path(base_filename))

  name_without_ext = File.basename(base_filename, ".md")
  counter = 1
  loop do
    numbered_filename = "#{name_without_ext}-#{counter}.md"
    return numbered_filename unless File.exist?(draft_path(numbered_filename))

    counter += 1
  end
end

def render_draft_template(title)
  now = Time.now
  <<~FRONTMATTER
    ---
    Author: #{current_author}
    Title: #{title}
    Date: unpublished
    Timestamp: #{now.strftime("%Y-%m-%dT%H:%M:%S%:z")}
    Tags:
    ---

    # #{title}

    TKTK
  FRONTMATTER
end

def current_author
  Etc.getlogin || ENV["USER"] || `whoami`.strip
rescue
  ENV["USER"] || `whoami`.strip
end

def ordinal_date(time)
  day = time.day
  suffix = case day
  when 1, 21, 31
    "st"
  when 2, 22
    "nd"
  when 3, 23
    "rd"
  else
    "th"
  end

  time.strftime("#{day}#{suffix} %B, %Y")
end
