require 'phlex'

module Pressa
  module Views
    class ProjectView < Phlex::HTML
      def initialize(project:, site:)
        @project = project
        @site = site
      end

      def view_template
        article(class: "project", data_title: @project.github_path) do
          header do
            h1 { @project.title }
            p(class: "description") { @project.description }
            p do
              a(href: @project.url) { "View on GitHub →" }
            end
          end

          section(class: "project-stats") do
            h2 { "Statistics" }
            div(id: "stats") do
              p { "Loading..." }
            end
          end

          section(class: "project-contributors") do
            h2 { "Contributors" }
            div(id: "contributors") do
              p { "Loading..." }
            end
          end

          section(class: "project-languages") do
            h2 { "Languages" }
            div(id: "languages") do
              p { "Loading..." }
            end
          end
        end
      end
    end
  end
end
