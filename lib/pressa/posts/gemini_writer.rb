require "pressa/utils/file_writer"
require "pressa/utils/gemtext_renderer"

module Pressa
  module Posts
    class GeminiWriter
      RECENT_POSTS_LIMIT = 20

      def initialize(site:, posts_by_year:)
        @site = site
        @posts_by_year = posts_by_year
      end

      def write_posts(target_path:)
        @posts_by_year.all_posts.each do |post|
          write_post(post:, target_path:)
        end
      end

      def write_recent_posts(target_path:, limit: RECENT_POSTS_LIMIT)
        rows = ["# #{@site.title}", ""]
        home_links.each do |link|
          label = link.label&.strip
          rows << if label.nil? || label.empty?
            "=> #{link.href}"
          else
            "=> #{link.href} #{label}"
          end
        end
        rows << "" unless home_links.empty?
        rows << "## Recent posts"
        rows << ""

        @posts_by_year.recent_posts(limit).each do |post|
          rows << post_link_line(post)
        end

        rows << ""
        rows << "=> #{web_url_for("/")} Website"
        rows << ""

        file_path = File.join(target_path, "index.gmi")
        Utils::FileWriter.write(path: file_path, content: rows.join("\n"))
      end

      def write_posts_index(target_path:)
        rows = ["# #{@site.title} posts", "## Feed", ""]

        @posts_by_year.all_posts.each do |post|
          rows.concat(post_listing_lines(post))
        end

        rows << ""
        rows << "=> / Home"
        rows << "=> #{web_url_for("/posts/")} Read on the web"
        rows << ""

        content = rows.join("\n")
        Utils::FileWriter.write(path: File.join(target_path, "posts", "index.gmi"), content:)
        Utils::FileWriter.write(path: File.join(target_path, "posts", "feed.gmi"), content:)
      end

      private

      def write_post(post:, target_path:)
        rows = ["# #{post.title}", "", "#{post.formatted_date} by #{post.author}", ""]

        if post.link_post?
          rows << "=> #{post.link}"
          rows << ""
        end

        gemtext_body = Utils::GemtextRenderer.render(post.markdown_body)
        rows << gemtext_body unless gemtext_body.empty?
        rows << "" unless rows.last.to_s.empty?

        rows << "=> /posts Back to posts"
        rows << "=> #{web_url_for("#{post.path}/")} Read on the web" if include_web_link?(post)
        rows << ""

        file_path = File.join(target_path, post.path.sub(%r{^/}, ""), "index.gmi")
        Utils::FileWriter.write(path: file_path, content: rows.join("\n"))
      end

      def post_link_line(post)
        "=> #{post.path}/ #{post.date.strftime("%Y-%m-%d")} - #{post.title}"
      end

      def post_listing_lines(post)
        rows = [post_link_line(post)]
        rows << "=> #{post.link}" if post.link_post?
        rows
      end

      def include_web_link?(post)
        markdown_without_fences = post.markdown_body.gsub(/```.*?```/m, "")
        markdown_without_fences.match?(
          %r{<\s*(?:a|p|div|span|ul|ol|li|audio|video|source|img|h[1-6]|blockquote|pre|code|table|tr|td|th|em|strong|br)\b}i
        )
      end

      def web_url_for(path)
        @site.url_for(path)
      end

      def home_links
        @site.gemini_output_options&.home_links || []
      end
    end
  end
end
