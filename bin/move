#!/usr/bin/env ruby

def pad(n)
  n = n.to_i
  if n < 10
    "0#{n}"
  else
    "#{n}"
  end
end

Dir.chdir File.join(File.dirname(__FILE__), '../public/posts')

Dir['*.html.md'].each do |filename|
  name = filename.sub('.html.md', '')
  date, *rest = name.split('-')
  year, month, _ = date.split('.')
  slug = rest.join('-')

  File.rename filename, File.join(year, pad(month), slug + '.html.md')
end
