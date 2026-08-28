require "fileutils"
require "pressa/drafts"
require "pressa/drafts/repo"

module Pressa
  module Web
    # The drafts directory as the web app sees it: list, read, write, create,
    # delete. Slugs arrive from URLs, so every path goes through the same
    # validation before it reaches the filesystem.
    class DraftStore
      class Error < StandardError; end

      class NotFound < Error; end

      class Conflict < Error; end

      class InvalidSlug < Error; end

      class InvalidTitle < Error; end

      # Exactly what Drafts.slugify produces, so nothing that could climb out
      # of the drafts directory can name a file.
      SLUG_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

      def initialize(dir: Drafts::DEFAULT_DIR)
        @dir = dir
      end

      def list
        return [] unless Dir.exist?(@dir)

        Drafts::Repo.new(dir: @dir).read_entries
      end

      def read(slug)
        File.read(path(slug))
      rescue Errno::ENOENT
        raise NotFound, "no draft named #{slug}"
      end

      def write(slug, content)
        target = path(slug)
        raise NotFound, "no draft named #{slug}" unless File.exist?(target)

        # Browsers normalize textarea line breaks to CRLF on submit, per the
        # HTML spec, even though nothing here ever inserts one.
        File.write(target, content.gsub("\r\n", "\n"))
      end

      def create(title, now: Time.now)
        title = title.to_s.strip
        slug = Drafts.slugify(title)
        raise InvalidTitle, "title cannot be converted to a filename: #{title.inspect}" unless slug.match?(SLUG_PATTERN)

        target = File.join(@dir, "#{slug}.md")
        raise Conflict, "a draft already exists at #{target}" if File.exist?(target)

        FileUtils.mkdir_p(@dir)
        File.write(target, drafts.render_template(title, now:))
        slug
      end

      def delete(slug)
        target = path(slug)
        raise NotFound, "no draft named #{slug}" unless File.exist?(target)

        FileUtils.rm_f(target)
      end

      def path(slug)
        raise InvalidSlug, "invalid draft name: #{slug.inspect}" unless slug.to_s.match?(SLUG_PATTERN)

        File.join(@dir, "#{slug}.md")
      end

      private

      def drafts
        @drafts ||= Drafts.new(dir: @dir)
      end
    end
  end
end
