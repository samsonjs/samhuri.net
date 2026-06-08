require "test_helper"

class Pressa::GitTest < Minitest::Test
  def test_choose_remote_prefers_github_over_origin
    assert_equal("github", Pressa::Git.choose_remote(remotes: ["origin", "github"]))
  end

  def test_choose_remote_falls_back_to_origin_when_no_github
    assert_equal("origin", Pressa::Git.choose_remote(remotes: ["origin", "mirror"]))
  end

  def test_choose_remote_falls_back_to_first_remote_when_neither_preferred
    assert_equal("mirror", Pressa::Git.choose_remote(remotes: ["mirror", "backup"]))
  end

  def test_choose_remote_honours_an_explicit_upstream_remote
    assert_equal("fork", Pressa::Git.choose_remote(remotes: ["origin", "github"], upstream_remote: "fork"))
  end

  def test_choose_remote_returns_upstream_even_without_other_remotes
    assert_equal("fork", Pressa::Git.choose_remote(remotes: [], upstream_remote: "fork"))
  end

  def test_choose_remote_raises_when_no_remotes_and_no_upstream
    error = assert_raises(Pressa::Git::Error) { Pressa::Git.choose_remote(remotes: []) }
    assert_match(/no git remotes/, error.message)
  end

  def test_choose_remote_accepts_a_custom_preference_order
    assert_equal("upstream", Pressa::Git.choose_remote(remotes: ["origin", "upstream"], preference: ["upstream"]))
  end
end
