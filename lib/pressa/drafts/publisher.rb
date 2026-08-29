require "fileutils"
require "pressa/drafts"
require "pressa/posts/metadata"

module Pressa
  class Drafts
    # Moves a draft out of the drafts directory and into posts/YYYY/MM, stamped
    # with its publication date.
    class Publisher
      class Error < StandardError; end

      class NotFound < Error; end

      class Conflict < Error; end

      class Invalid < Error; end

      Result = Data.define(:draft_path, :target_path)

      def initialize(drafts_dir: Drafts::DEFAULT_DIR, posts_dir: "posts")
        @drafts = Drafts.new(dir: drafts_dir)
        @posts_dir = posts_dir
      end

      def publish(input_path, now: Time.now)
        draft_path, filename = resolve(input_path)
        raise NotFound, "file not found: #{draft_path}" unless File.exist?(draft_path)

        content = self.class.rewrite(File.read(draft_path), now:)
        target_path = File.join(@posts_dir, now.strftime("%Y/%m"), filename)
        raise Conflict, "post already exists at #{target_path}" if File.exist?(target_path)

        FileUtils.mkdir_p(File.dirname(target_path))
        File.write(target_path, content)
        FileUtils.rm_f(draft_path)

        Result.new(draft_path:, target_path:)
      end

      # Stamps the draft with the date it's being published on, then checks the
      # result against the same parser the build uses. bin/publish-draft commits
      # and pushes before it builds, so a draft that can't become a valid post
      # has to fail here rather than halfway through a deploy.
      def self.rewrite(content, now:)
        updated = content
          .sub(/^Date:.*$/, "Date: #{Drafts.ordinal_date(now)}")
          .sub(/^Timestamp:.*$/, "Timestamp: #{now.strftime("%Y-%m-%dT%H:%M:%S%:z")}")

        begin
          Posts::PostMetadata.parse(updated)
        rescue => e
          raise Invalid, "draft cannot be published: #{e.message}"
        end

        updated
      end

      private

      def resolve(input_path)
        @drafts.resolve_input(input_path)
      rescue Drafts::Error => e
        raise Error, e.message
      end
    end
  end
end
