require_relative 'site'
require_relative 'site_generator'
require_relative 'plugin'
require_relative 'posts/plugin'
require_relative 'projects/plugin'
require_relative 'utils/markdown_renderer'

module Pressa
  def self.create_site(url_override: nil)
    url = url_override || 'https://samhuri.net'

    build_project = lambda do |name, title, description|
      Projects::Project.new(
        name:,
        title:,
        description:,
        url: "https://github.com/samsonjs/#{title}"
      )
    end

    projects = [
      build_project.call('bin', 'bin', 'my collection of scripts in ~/bin'),
      build_project.call('config', 'config', 'important dot files (zsh, emacs, vim, screen)'),
      build_project.call('compiler', 'compiler', 'a compiler targeting x86 in Ruby'),
      build_project.call('lake', 'lake', 'a simple implementation of Scheme in C'),
      build_project.call('strftime', 'strftime', 'strftime for JavaScript'),
      build_project.call('format', 'format', 'printf for JavaScript'),
      build_project.call('gitter', 'gitter', 'a GitHub client for Node (v3 API)'),
      build_project.call('mojo.el', 'mojo.el', 'turn emacs into a sweet mojo editor'),
      build_project.call('ThePusher', 'ThePusher', 'Github post-receive hook router'),
      build_project.call('NorthWatcher', 'NorthWatcher', 'cron for filesystem changes'),
      build_project.call('repl-edit', 'repl-edit', 'edit Node repl commands with your text editor'),
      build_project.call('cheat.el', 'cheat.el', 'cheat from emacs'),
      build_project.call('batteries', 'batteries', 'a general purpose node library'),
      build_project.call('samhuri.net', 'samhuri.net', 'this site')
    ]

    project_scripts = [
      Script.new(src: 'https://ajax.googleapis.com/ajax/libs/prototype/1.6.1.0/prototype.js', defer: true),
      Script.new(src: 'js/gitter.js', defer: true),
      Script.new(src: 'js/store.js', defer: true),
      Script.new(src: 'js/projects.js', defer: true)
    ]

    Site.new(
      author: 'Sami Samhuri',
      email: 'sami@samhuri.net',
      title: 'samhuri.net',
      description: "Sami Samhuri's blog about programming, mainly about iOS and Ruby and Rails these days.",
      url:,
      image_url: "#{url}/images/me.jpg",
      scripts: [],
      styles: [
        Stylesheet.new(href: 'css/normalize.css'),
        Stylesheet.new(href: 'css/style.css'),
        Stylesheet.new(href: 'css/syntax.css'),
        Stylesheet.new(href: 'css/fontawesome.min.css'),
        Stylesheet.new(href: 'css/brands.min.css'),
        Stylesheet.new(href: 'css/solid.min.css')
      ],
      plugins: [
        Posts::Plugin.new,
        Projects::Plugin.new(projects:, scripts: project_scripts, styles: [])
      ],
      renderers: [
        Utils::MarkdownRenderer.new
      ]
    )
  end
end
