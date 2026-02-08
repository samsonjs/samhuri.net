require "test_helper"

class Pressa::Projects::ModelsTest < Minitest::Test
  def test_project_helpers_compute_paths
    project = Pressa::Projects::Project.new(
      name: "demo",
      title: "Demo",
      description: "Demo project",
      url: "https://github.com/samsonjs/demo"
    )

    assert_equal("samsonjs/demo", project.github_path)
    assert_equal("/projects/demo", project.path)
  end
end
