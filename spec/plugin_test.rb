require "test_helper"

class Pressa::PluginTest < Minitest::Test
  def test_setup_requires_subclass_implementation
    plugin = Pressa::Plugin.new

    error = assert_raises(NotImplementedError) do
      plugin.setup(site: Object.new, source_path: "/tmp/source")
    end

    assert_match(/Pressa::Plugin#setup must be implemented/, error.message)
  end

  def test_render_requires_subclass_implementation
    plugin = Pressa::Plugin.new

    error = assert_raises(NotImplementedError) do
      plugin.render(site: Object.new, target_path: "/tmp/target")
    end

    assert_match(/Pressa::Plugin#render must be implemented/, error.message)
  end
end
