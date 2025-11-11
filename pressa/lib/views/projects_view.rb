require 'phlex'

module Pressa
  module Views
    class ProjectsView < Phlex::HTML
      def initialize(projects:, site:)
        @projects = projects
        @site = site
      end

      def view_template
        article(class: "projects") do
          h1 { "Projects" }

          p { "Open source projects I've created or contributed to." }

          ul(class: "projects-list") do
            @projects.each do |project|
              li do
                a(href: @site.url_for(project.path)) { project.title }
                plain " – #{project.description}"
              end
            end
          end
        end
      end
    end
  end
end
