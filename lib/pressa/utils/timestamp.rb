require "date"

module Pressa
  module Utils
    # The one place a Timestamp front-matter value becomes a DateTime. Posts and
    # drafts both carry them, and older ones are bare Unix integers rather than
    # ISO 8601 strings, so anything that reads front matter has to cope with
    # both. There used to be two copies of this and only one of them did.
    module Timestamp
      def self.parse(value)
        case value
        when String then DateTime.parse(value)
        when Integer then Time.at(value).to_datetime
        when Time, Date, DateTime then value.to_datetime
        else raise ArgumentError, "cannot read a timestamp from #{value.inspect}"
        end
      end
    end
  end
end
