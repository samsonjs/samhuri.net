require "dry-struct"
require "pressa/site"

module Pressa
  module Posts
    class Post < Dry::Struct
      attribute :slug, Types::String
      attribute :title, Types::String
      attribute :author, Types::String
      attribute :date, Types::Params::DateTime
      attribute :formatted_date, Types::String
      attribute :link, Types::String.optional.default(nil)
      attribute :tags, Types::Array.of(Types::String).default([].freeze)
      attribute :body, Types::String
      attribute :excerpt, Types::String
      attribute :path, Types::String

      def link_post?
        !link.nil?
      end

      def year
        date.year
      end

      def month
        date.month
      end

      def formatted_month
        date.strftime("%B")
      end

      def padded_month
        format("%02d", month)
      end
    end

    class Month < Dry::Struct
      attribute :name, Types::String
      attribute :number, Types::Integer
      attribute :padded, Types::String

      def self.from_date(date)
        new(
          name: date.strftime("%B"),
          number: date.month,
          padded: format("%02d", date.month)
        )
      end
    end

    class MonthPosts < Dry::Struct
      attribute :month, Month
      attribute :posts, Types::Array.of(Post)

      def sorted_posts
        posts.sort_by(&:date).reverse
      end
    end

    class YearPosts < Dry::Struct
      attribute :year, Types::Integer
      attribute :by_month, Types::Hash.map(Types::Integer, MonthPosts)

      def sorted_months
        by_month.keys.sort.reverse.map { |month_num| by_month[month_num] }
      end

      def all_posts
        by_month.values.flat_map(&:posts).sort_by(&:date).reverse
      end
    end

    class PostsByYear < Dry::Struct
      attribute :by_year, Types::Hash.map(Types::Integer, YearPosts)

      def sorted_years
        by_year.keys.sort.reverse
      end

      def all_posts
        by_year.values.flat_map(&:all_posts).sort_by(&:date).reverse
      end

      def recent_posts(limit = 10)
        all_posts.take(limit)
      end
    end
  end
end
