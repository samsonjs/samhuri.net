require "pressa/posts/tag_index"

module Pressa
  module Posts
    # Renders TagIndex data as plain text for the terminal: a frequency table
    # and a tag-by-year sparkline so trends are visible at a glance.
    class TagReport
      SPARK_CHARS = %w[▁ ▂ ▃ ▄ ▅ ▆ ▇ █].freeze

      def self.from_posts_by_year(posts_by_year)
        new(TagIndex.from_posts_by_year(posts_by_year))
      end

      def initialize(tag_index)
        @tag_index = tag_index
      end

      def to_s
        "#{counts_table}\n\n#{sparkline_table}"
      end

      private

      def counts_table
        rows = @tag_index.counts.map { |tag, count| [tag, count.to_s] }
        tag_width = ([3] + rows.map { |tag, _| tag.length }).max

        lines = ["Tags by post count", "-" * 18]
        rows.each { |tag, count| lines << "#{tag.ljust(tag_width)}  #{count}" }
        lines.join("\n")
      end

      def sparkline_table
        years = @tag_index.years
        tag_width = ([3] + @tag_index.tags.map(&:length)).max

        lines = ["Tags over time (#{years.first}-#{years.last})", "-" * 30]
        @tag_index.tags.each do |tag|
          counts_by_year = @tag_index.counts_by_tag_and_year.fetch(tag, {})
          lines << "#{tag.ljust(tag_width)}  #{sparkline(counts_by_year, years)}"
        end
        lines.join("\n")
      end

      def sparkline(counts_by_year, years)
        max = counts_by_year.values.max || 1
        years.map do |year|
          count = counts_by_year[year] || 0
          next " " if count.zero?

          index = ((count / max.to_f) * (SPARK_CHARS.size - 1)).round
          SPARK_CHARS[index]
        end.join
      end
    end
  end
end
