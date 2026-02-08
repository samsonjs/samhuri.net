require "phlex"
require "pressa/views/icons"

module Pressa
  module Views
    class ProjectView < Phlex::HTML
      def initialize(project:, site:)
        @project = project
        @site = site
      end

      def view_template
        article(class: "container project") do
          h1(id: "project", data: {title: @project.title}) { @project.title }
          h4 { @project.description }

          div(class: "project-stats") do
            p do
              a(href: @project.url) { "GitHub" }
              plain " • "
              a(id: "nstar", href: stargazers_url)
              plain " • "
              a(id: "nfork", href: network_url)
            end

            p do
              plain "Last updated on "
              span(id: "updated")
            end
          end

          div(class: "project-info row clearfix") do
            div(class: "column half") do
              h3 { "Contributors" }
              div(id: "contributors")
            end

            div(class: "column half") do
              h3 { "Languages" }
              div(id: "langs")
            end
          end
        end

        div(class: "row clearfix") do
          p(class: "fin") do
            raw(safe(Icons.code))
          end
        end
      end

      private

      def stargazers_url
        "#{@project.url}/stargazers"
      end

      def network_url
        "#{@project.url}/network/members"
      end
    end
  end
end
