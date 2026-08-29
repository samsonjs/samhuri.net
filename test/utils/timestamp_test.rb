require "test_helper"
require "pressa/utils/timestamp"

class Pressa::Utils::TimestampTest < Minitest::Test
  def parse(value) = Pressa::Utils::Timestamp.parse(value)

  def test_parses_an_iso8601_string
    assert_equal(DateTime.parse("2026-06-07T14:30:00-07:00"), parse("2026-06-07T14:30:00-07:00"))
  end

  # Older drafts and posts carry a bare Unix timestamp.
  def test_parses_a_unix_integer
    assert_equal(Time.at(1503246688).to_datetime, parse(1503246688))
  end

  def test_parses_a_time_yaml_already_turned_into_an_object
    time = Time.new(2026, 6, 7, 14, 30, 0, "-07:00")

    assert_equal(time.to_datetime, parse(time))
  end

  def test_parses_a_date
    assert_equal(Date.new(2026, 6, 7).to_datetime, parse(Date.new(2026, 6, 7)))
  end

  def test_refuses_something_it_cannot_read
    assert_raises(ArgumentError) { parse(nil) }
    assert_raises(ArgumentError) { parse([]) }
  end
end
