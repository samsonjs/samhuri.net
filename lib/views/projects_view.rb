require 'phlex'
require_relative 'icons'

module Pressa
  module Views
    class ProjectsView < Phlex::HTML
      def initialize(projects:, site:)
        @projects = projects
        @site = site
      end

      def view_template
        article(class: 'container') do
          h1 { 'Projects' }

          @projects.each do |project|
            div(class: 'project-listing') do
              h4 do
                a(href: @site.url_for(project.path)) { project.title }
              end
              p(class: 'description') { project.description }
            end
          end
        end

        div(class: 'row clearfix') do
          p(class: 'fin') do
            raw(safe(Icons.code))
          end
        end
      end
    end
  end
end
