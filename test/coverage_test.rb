require "test_helper"

class Pressa::CoverageTest < Minitest::Test
  def test_parse_percent_extracts_the_lib_coverage_figure
    output = "Coverage (lib): 98.89% (1597 / 1615 lines)\nLowest covered files:\n"
    assert_in_delta(98.89, Pressa::Coverage.parse_percent(output), 0.0001)
  end

  def test_parse_percent_raises_when_the_marker_is_missing
    error = assert_raises(Pressa::Coverage::Error) { Pressa::Coverage.parse_percent("nothing useful here") }
    assert_match(/unable to parse/, error.message)
  end

  def test_script_filters_to_lib_and_reports_the_lib_marker
    script = Pressa::Coverage.script(lowest_count: 10)
    assert_match(/lib_root/, script)
    assert_match(/Coverage \(lib\):/, script)
  end

  def test_script_interpolates_the_lowest_count
    assert_match(/unless 0\.zero\?/, Pressa::Coverage.script(lowest_count: 0))
    assert_match(/unless 5\.zero\?/, Pressa::Coverage.script(lowest_count: 5))
  end

  def test_resolve_baseline_ref_returns_explicit_ref_without_yielding
    yielded = false
    ref = Pressa::Coverage.resolve_baseline_ref("v1.2.3") { yielded = true }
    assert_equal("v1.2.3", ref)
    refute(yielded, "merge-base block should not run for an explicit ref")
  end

  def test_resolve_baseline_ref_yields_for_merge_base
    ref = Pressa::Coverage.resolve_baseline_ref("merge-base") { "abc1234" }
    assert_equal("abc1234", ref)
  end

  def test_resolve_baseline_ref_rejects_blank_baselines
    error = assert_raises(Pressa::Coverage::Error) { Pressa::Coverage.resolve_baseline_ref("   ") {} }
    assert_match(/cannot be empty/, error.message)
  end
end
