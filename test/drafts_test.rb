require "test_helper"

class Pressa::DraftsTest < Minitest::Test
  def test_slugify_lowercases_and_hyphenates
    assert_equal("powder-day-at-baker", Pressa::Drafts.slugify("Powder Day at Baker"))
  end

  def test_slugify_strips_symbols_and_squeezes_separators
    assert_equal("nine-inch-nails-the-fragile", Pressa::Drafts.slugify("Nine Inch Nails: The Fragile!!!"))
  end

  def test_slugify_trims_leading_and_trailing_hyphens
    assert_equal("hello", Pressa::Drafts.slugify("  ...Hello...  "))
  end

  def test_slugify_returns_empty_string_for_symbol_only_titles
    assert_equal("", Pressa::Drafts.slugify("!!!"))
  end

  def test_ordinal_date_uses_st_nd_rd_suffixes
    assert_equal("1st June, 2026", Pressa::Drafts.ordinal_date(Time.new(2026, 6, 1)))
    assert_equal("2nd June, 2026", Pressa::Drafts.ordinal_date(Time.new(2026, 6, 2)))
    assert_equal("3rd June, 2026", Pressa::Drafts.ordinal_date(Time.new(2026, 6, 3)))
    assert_equal("21st June, 2026", Pressa::Drafts.ordinal_date(Time.new(2026, 6, 21)))
    assert_equal("31st March, 2026", Pressa::Drafts.ordinal_date(Time.new(2026, 3, 31)))
  end

  def test_ordinal_date_uses_th_for_the_teens
    assert_equal("11th June, 2026", Pressa::Drafts.ordinal_date(Time.new(2026, 6, 11)))
    assert_equal("12th June, 2026", Pressa::Drafts.ordinal_date(Time.new(2026, 6, 12)))
    assert_equal("13th June, 2026", Pressa::Drafts.ordinal_date(Time.new(2026, 6, 13)))
  end

  def test_path_joins_filename_with_drafts_dir
    drafts = Pressa::Drafts.new(dir: "public/drafts")
    assert_equal("public/drafts/the-fragile.md", drafts.path("the-fragile.md"))
  end

  def test_next_available_returns_base_filename_when_free
    drafts = Pressa::Drafts.new(dir: "public/drafts", exists: ->(_path) { false })
    assert_equal("untitled.md", drafts.next_available)
  end

  def test_next_available_appends_counter_on_collision
    taken = ["public/drafts/untitled.md", "public/drafts/untitled-1.md"]
    drafts = Pressa::Drafts.new(dir: "public/drafts", exists: ->(path) { taken.include?(path) })
    assert_equal("untitled-2.md", drafts.next_available)
  end

  def test_resolve_input_treats_bare_name_as_draft_filename
    drafts = Pressa::Drafts.new(dir: "public/drafts")
    assert_equal(["public/drafts/the-fragile.md", "the-fragile.md"], drafts.resolve_input("the-fragile.md"))
  end

  def test_resolve_input_uses_explicit_path_verbatim
    drafts = Pressa::Drafts.new(dir: "public/drafts")
    assert_equal(
      ["public/drafts/the-fragile.md", "the-fragile.md"],
      drafts.resolve_input("public/drafts/the-fragile.md")
    )
  end

  def test_resolve_input_rejects_already_published_paths
    drafts = Pressa::Drafts.new(dir: "public/drafts")
    error = assert_raises(Pressa::Drafts::Error) { drafts.resolve_input("posts/2026/06/the-fragile.md") }
    assert_match(/already published/, error.message)
  end

  def test_current_author_returns_a_non_empty_login
    assert_kind_of(String, Pressa::Drafts.current_author)
    refute_empty(Pressa::Drafts.current_author)
  end

  def test_current_author_falls_back_when_getlogin_raises
    original = Etc.method(:getlogin)
    Etc.define_singleton_method(:getlogin) { raise "no login on this box" }
    assert_kind_of(String, Pressa::Drafts.current_author)
    refute_empty(Pressa::Drafts.current_author)
  ensure
    Etc.define_singleton_method(:getlogin, original)
  end

  def test_render_template_includes_front_matter_and_title
    drafts = Pressa::Drafts.new(dir: "public/drafts")
    content = drafts.render_template("The Downward Spiral", author: "Trent Reznor", now: Time.new(2026, 6, 7, 9, 30, 0))

    assert_match(/^Author: Trent Reznor$/, content)
    assert_match(/^Title: The Downward Spiral$/, content)
    assert_match(/^Date: unpublished$/, content)
    assert_match(/^Timestamp: 2026-06-07T09:30:00/, content)
    assert_match(/^# The Downward Spiral$/, content)
  end
end
