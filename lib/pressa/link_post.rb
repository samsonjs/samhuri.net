require "pressa/drafts"

module Pressa
  # Builds a fully-formed, ready-to-publish link post (front matter + body) from
  # the handful of fields a phone Shortcut can collect. Pure: returns the target
  # path and content; writing the file is the caller's job.
  class LinkPost
    class Error < StandardError; end

    Result = Data.define(:filename, :target_path, :content)

    def self.build(title:, link:, body: nil, tags: nil, image: nil, author: Drafts.current_author, now: Time.now)
      title = title.to_s.strip
      raise Error, "title cannot be empty" if title.empty?

      link = link.to_s.strip
      raise Error, "link cannot be empty" if link.empty?

      slug = Drafts.slugify(title)
      raise Error, "title cannot be converted to a filename: #{title.inspect}" if slug.empty?

      filename = "#{slug}.md"
      target_path = "posts/#{now.strftime("%Y/%m")}/#{filename}"
      content = render(title:, link:, body:, tags:, image:, author:, now:)

      Result.new(filename:, target_path:, content:)
    end

    def self.render(title:, link:, body:, tags:, image:, author:, now:)
      lines = [
        "---",
        "Title: #{yaml_quote(title)}",
        "Author: #{author}",
        "Date: #{yaml_quote(Drafts.ordinal_date(now))}",
        "Timestamp: #{now.strftime("%Y-%m-%dT%H:%M:%S%:z")}"
      ]
      tag_list = normalize_tags(tags)
      lines << "Tags: #{tag_list.join(", ")}" unless tag_list.empty?
      lines << "Link: #{link}"
      image = image.to_s.strip
      lines << "Image: #{image}" unless image.empty?
      lines << "---"

      front_matter = lines.join("\n")
      body = body.to_s.strip
      body.empty? ? "#{front_matter}\n" : "#{front_matter}\n\n#{body}\n"
    end

    def self.normalize_tags(tags)
      return [] if tags.nil?

      list = tags.is_a?(Array) ? tags : tags.to_s.split(",")
      list.map(&:strip).reject(&:empty?)
    end

    # YAML double-quoted scalar so titles with colons, quotes, or backslashes
    # round-trip cleanly through the front-matter parser.
    def self.yaml_quote(value)
      escaped = value.gsub("\\", "\\\\\\\\").gsub('"', '\\"')
      %("#{escaped}")
    end
  end
end
