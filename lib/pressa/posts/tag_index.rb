require "pressa/drafts"

module Pressa
  module Posts
    # Derives tag counts and per-tag/per-year breakdowns from a flat list of posts.
    class TagIndex
      def self.from_posts_by_year(posts_by_year)
        new(posts_by_year.all_posts)
      end

      def initialize(posts)
        @posts = posts
      end

      def tags
        counts.keys
      end

      def counts
        @counts ||= @posts.each_with_object(Hash.new(0)) do |post, tally|
          post.tags.each { |tag| tally[tag] += 1 }
        end.sort_by { |tag, count| [-count, tag] }.to_h
      end

      def posts_for(tag)
        @posts.select { |post| post.tags.include?(tag) }.sort_by(&:date).reverse
      end

      def years
        @posts.map(&:year).uniq.sort
      end

      def counts_by_tag_and_year
        @counts_by_tag_and_year ||= @posts.each_with_object(Hash.new { |h, k| h[k] = Hash.new(0) }) do |post, tally|
          post.tags.each { |tag| tally[tag][post.year] += 1 }
        end
      end

      def slug(tag)
        Drafts.slugify(tag)
      end
    end
  end
end
