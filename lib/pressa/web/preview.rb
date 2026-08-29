require "pressa/posts/gemini_writer"
require "pressa/posts/models"
require "pressa/posts/repo"
require "pressa/posts/writer"

module Pressa
  module Web
    # Renders one post's source as both a web page and a gemtext capsule page,
    # through the same writers the build uses, so formatting problems show up
    # before publishing rather than after.
    class Preview
      class Error < StandardError; end

      Result = Data.define(:title, :html, :gemtext)

      # The preview iframe uses srcdoc, so it runs on the web app's origin while
      # the rendered page points its assets at the live site. A stylesheet
      # crosses origins happily; a module script is fetched in CORS mode and
      # samhuri.net sends no Access-Control-Allow-Origin, so the highlighter
      # would never load. Point it back at this app, which serves the same
      # vendored files from the checkout.
      HIGHLIGHTER_PATH = "/js/microlighter/"

      def initialize(html_site:, gemini_site:)
        @html_site = html_site
        @gemini_site = gemini_site
      end

      def render(source, slug:)
        post =
          begin
            Posts::PostRepo.new.build_post(content: source, slug:)
          rescue => e
            raise Error, e.message
          end

        Result.new(
          title: post.title,
          html: same_origin_highlighter(html_writer.post_html(post:)),
          gemtext: gemini_writer.post_content(post:)
        )
      end

      private

      def same_origin_highlighter(html)
        html.gsub("#{@html_site.url}#{HIGHLIGHTER_PATH}", HIGHLIGHTER_PATH)
      end

      # Neither post_html nor post_content consults the index, and a preview
      # has no site to index anyway.
      def empty_index
        Posts::PostsByYear.new(by_year: {})
      end

      def html_writer
        @html_writer ||= Posts::PostWriter.new(site: @html_site, posts_by_year: empty_index)
      end

      def gemini_writer
        @gemini_writer ||= Posts::GeminiWriter.new(site: @gemini_site, posts_by_year: empty_index)
      end
    end
  end
end
