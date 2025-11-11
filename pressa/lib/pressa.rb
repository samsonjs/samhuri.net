require_relative 'site'
require_relative 'site_generator'
require_relative 'plugin'
require_relative 'posts/plugin'
require_relative 'projects/plugin'
require_relative 'utils/markdown_renderer'

module Pressa
  def self.create_site(url_override: nil)
    url = url_override || 'https://samhuri.net'

    projects = [
      Projects::Project.new(
        name: 'bin',
        title: 'bin',
        description: 'my collection of scripts in ~/bin',
        url: 'https://github.com/samsonjs/bin'
      ),
      Projects::Project.new(
        name: 'config',
        title: 'config',
        description: 'important dot files',
        url: 'https://github.com/samsonjs/config'
      ),
      Projects::Project.new(
        name: 'unix-node',
        title: 'unix-node',
        description: 'Node.js CommonJS module that exports useful Unix commands',
        url: 'https://github.com/samsonjs/unix-node'
      ),
      Projects::Project.new(
        name: 'strftime',
        title: 'strftime',
        description: 'strftime for JavaScript',
        url: 'https://github.com/samsonjs/strftime'
      )
    ]

    Site.new(
      author: 'Sami Samhuri',
      email: 'sami@samhuri.net',
      title: 'samhuri.net',
      description: 'The personal blog of Sami Samhuri',
      url:,
      image_url: "#{url}/images",
      scripts: [],
      styles: [
        Stylesheet.new(href: 'css/style.css')
      ],
      plugins: [
        Posts::Plugin.new,
        Projects::Plugin.new(projects:)
      ],
      renderers: [
        Utils::MarkdownRenderer.new
      ]
    )
  end
end
