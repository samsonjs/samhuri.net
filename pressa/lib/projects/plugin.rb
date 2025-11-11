require_relative '../plugin'
require_relative '../utils/file_writer'
require_relative '../views/layout'
require_relative '../views/projects_view'
require_relative '../views/project_view'
require_relative 'models'

module Pressa
  module Projects
    class Plugin < Pressa::Plugin
      def initialize(projects: [])
        @projects = projects
      end

      def setup(site:, source_path:)
      end

      def render(site:, target_path:)
        write_projects_index(site:, target_path:)

        @projects.each do |project|
          write_project_page(project:, site:, target_path:)
        end
      end

      private

      def write_projects_index(site:, target_path:)
        content_view = Views::ProjectsView.new(projects: @projects, site:)

        html = render_layout(
          site:,
          page_title: "Projects – #{site.title}",
          canonical_url: site.url_for('/projects/'),
          content: content_view
        )

        file_path = File.join(target_path, 'projects', 'index.html')
        Utils::FileWriter.write(path: file_path, content: html)
      end

      def write_project_page(project:, site:, target_path:)
        content_view = Views::ProjectView.new(project:, site:)

        html = render_layout(
          site:,
          page_title: "#{project.title} – #{site.title}",
          canonical_url: site.url_for(project.path),
          content: content_view
        )

        file_path = File.join(target_path, 'projects', project.name, 'index.html')
        Utils::FileWriter.write(path: file_path, content: html)
      end

      def render_layout(site:, page_title:, canonical_url:, content:)
        layout = Views::Layout.new(
          site:,
          page_title:,
          canonical_url:
        )

        layout.call do
          content.call
        end
      end
    end
  end
end
