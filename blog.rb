#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'rdiscount'
require 'mustache'

srcdir = ARGV.shift.to_s
destdir = ARGV.shift.to_s

unless File.directory?(srcdir) && File.directory?(destdir)
  puts 'usage: blog.rb <source dir> <dest dir>'
  exit 1
end

template = File.read(File.join('templates', 'blog', 'post.html'))

# read posts
posts_file = File.join(srcdir, 'posts.json')
Posts = JSON.parse(File.read(posts_file))
posts = Posts['published'].map do |filename|
  lines = File.readlines(File.join(srcdir, filename))
  post = { :filename => filename }
  loop do
    line = lines.shift.strip
    m = line.match(/(\w+):/)
    if m && param = m[1].downcase
      post[param.to_sym] = line.sub(Regexp.new('^' + param + ':\s*', 'i'), '').strip
    elsif line.match(/^----\s*$/)
      lines.shift while lines.first.strip.empty?
      break
    else
      puts "ignoring unknown header: #{line}"
    end
  end
  post[:content] = lines.join
  post[:body] = RDiscount.new(post[:content]).to_html
  # comments on by default
  post[:comments] = true if post[:comments].nil?
  post
end

# generate posts
posts.each_with_index do |post, i|
  post[:html] = Mustache.render(template, { :title => post[:title],
                                            :post => post,
                                            :previous => i < posts.length - 1 && posts[i + 1],
                                            :next => i > 0 && posts[i - 1],
                                            :comments => post[:comments]
                                          })
end

# generate landing page
index_template = File.read(File.join('templates', 'blog', 'index.html'))
index_html = Mustache.render(index_template, { :posts => posts,
                                               :post => posts.first,
                                               :previous => posts[1]
                                             })

# write landing page
File.open(File.join(destdir, 'index.html'), 'w') {|f| f.puts(index_html) }

# write posts
posts.each do |post|
  File.open(File.join(destdir, post[:filename]), 'w') {|f| f.puts(post[:html]) }
end
