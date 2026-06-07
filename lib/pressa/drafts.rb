require "etc"

module Pressa
  # Draft authoring logic: slugs, paths, ordinal dates, and the new-draft template.
  # File mutation (writing, moving, date rewriting) stays in the bake tasks that call this.
  class Drafts
    class Error < StandardError; end

    DEFAULT_DIR = "public/drafts".freeze

    def self.slugify(title)
      title.downcase
        .gsub(/[^a-z0-9\s-]/, "")
        .gsub(/\s+/, "-").squeeze("-")
        .gsub(/^-|-$/, "")
    end

    def self.ordinal_date(time)
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

    def self.current_author
      Etc.getlogin || ENV["USER"] || `whoami`.strip
    rescue
      ENV["USER"] || `whoami`.strip
    end

    def initialize(dir: DEFAULT_DIR, exists: ->(path) { File.exist?(path) })
      @dir = dir
      @exists = exists
    end

    def path(filename)
      File.join(@dir, filename)
    end

    def next_available(base_filename = "untitled.md")
      return base_filename unless @exists.call(path(base_filename))

      name_without_ext = File.basename(base_filename, ".md")
      counter = 1
      loop do
        numbered_filename = "#{name_without_ext}-#{counter}.md"
        return numbered_filename unless @exists.call(path(numbered_filename))

        counter += 1
      end
    end

    def resolve_input(input_path)
      if input_path.include?("/")
        if input_path.start_with?("posts/")
          raise Error, "'#{input_path}' is already published in posts/ directory"
        end

        [input_path, File.basename(input_path)]
      else
        [path(input_path), input_path]
      end
    end

    def render_template(title, author: self.class.current_author, now: Time.now)
      <<~FRONTMATTER
        ---
        Author: #{author}
        Title: #{title}
        Date: unpublished
        Timestamp: #{now.strftime("%Y-%m-%dT%H:%M:%S%:z")}
        Tags:
        ---

        # #{title}

        TKTK
      FRONTMATTER
    end
  end
end
