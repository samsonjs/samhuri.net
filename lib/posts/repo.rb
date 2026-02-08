require 'kramdown'
require_relative 'models'
require_relative 'metadata'

module Pressa
  module Posts
    class PostRepo
      EXCERPT_LENGTH = 300

      def initialize(output_path: 'posts')
        @output_path = output_path
        @posts_by_year = {}
      end

      def read_posts(posts_dir)
        enumerate_markdown_files(posts_dir) do |file_path|
          post = read_post(file_path)
          add_post_to_hierarchy(post)
        end

        PostsByYear.new(by_year: @posts_by_year)
      end

      private

      def enumerate_markdown_files(dir, &block)
        Dir.glob(File.join(dir, '**', '*.md')).each(&block)
      end

      def read_post(file_path)
        content = File.read(file_path)
        metadata = PostMetadata.parse(content)

        body_markdown = content.sub(/\A---\s*\n.*?\n---\s*\n/m, '')

        html_body = render_markdown(body_markdown)

        slug = File.basename(file_path, '.md')
        path = generate_path(slug, metadata.date)
        excerpt = generate_excerpt(body_markdown)

        Post.new(
          slug:,
          title: metadata.title,
          author: metadata.author,
          date: metadata.date,
          formatted_date: metadata.formatted_date,
          link: metadata.link,
          tags: metadata.tags,
          scripts: metadata.scripts,
          styles: metadata.styles,
          body: html_body,
          excerpt:,
          path:
        )
      end

      def render_markdown(markdown)
        Kramdown::Document.new(
          markdown,
          input: 'GFM',
          hard_wrap: false,
          syntax_highlighter: 'rouge',
          syntax_highlighter_opts: {
            line_numbers: false,
            wrap: true
          }
        ).to_html
      end

      def generate_path(slug, date)
        year = date.year
        month = format('%02d', date.month)
        "/#{@output_path}/#{year}/#{month}/#{slug}"
      end

      def generate_excerpt(markdown)
        text = markdown.dup

        text.gsub!(/!\[[^\]]*\]\([^)]+\)/, '')
        text.gsub!(/!\[[^\]]*\]\[[^\]]+\]/, '')

        text.gsub!(/\[([^\]]+)\]\([^)]+\)/, '\1')
        text.gsub!(/\[([^\]]+)\]\[[^\]]+\]/, '\1')

        text.gsub!(/(?m)^\[[^\]]+\]:\s*\S.*$/, '')

        text.gsub!(/<[^>]+>/, '')

        text.gsub!(/\s+/, ' ')
        text.strip!

        return '...' if text.empty?

        "#{text[0...EXCERPT_LENGTH]}..."
      end

      def add_post_to_hierarchy(post)
        year = post.year
        month_num = post.month

        @posts_by_year[year] ||= create_year_posts(year)
        year_posts = @posts_by_year[year]

        month_posts = year_posts.by_month[month_num]
        if month_posts
          updated_posts = month_posts.posts + [post]
          year_posts.by_month[month_num] = MonthPosts.new(
            month: month_posts.month,
            posts: updated_posts
          )
        else
          month = Month.from_date(post.date)
          year_posts.by_month[month_num] = MonthPosts.new(
            month:,
            posts: [post]
          )
        end
      end

      def create_year_posts(year)
        YearPosts.new(year:, by_month: {})
      end
    end
  end
end
