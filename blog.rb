#!/usr/bin/env ruby

require 'time'
require 'rubygems'
require 'builder'
require 'json'
require 'mustache'
require 'rdiscount'

def main
  srcdir = ARGV.shift.to_s
  destdir = ARGV.shift.to_s
  unless File.directory?(srcdir) && File.directory?(destdir)
    puts 'usage: blog.rb <source dir> <dest dir>'
    exit 1
  end
  b = Blag.new srcdir, destdir
  puts 'title: ' + b.title
  puts 'subtitle: ' + b.subtitle
  puts 'url: ' + b.url
  puts "#{b.posts.size} posts"
  b.generate!
  puts 'done blog'
end

class Blag
  attr_accessor :title, :subtitle, :url

  def self.go! src, dest
    self.new(src, dest).generate!
  end

  def initialize src, dest
    @src = src
    @dest = dest
    read_blog
  end

  def generate!
    generate_posts
    generate_index
    generate_rss
    generate_posts_json
  end

  def generate_index
    template = File.read(File.join('templates', 'blog', 'index.html'))
    # generate landing page
    index_template = File.read(File.join('templates', 'blog', 'index.html'))
    index_html = Mustache.render(index_template, { :posts => posts,
                                                   :post => posts.first,
                                                   :previous => posts[1],
                                                   :filename => posts.first[:filename],
                                                   :comments => posts.first[:comments]
                                 })
    File.open(File.join(@dest, 'index.html'), 'w') {|f| f.puts(index_html) }
  end

  def generate_posts
    template = File.read(File.join('templates', 'blog', 'post.html'))
    posts.each_with_index do |post, i|
      post[:html] = Mustache.render(template, { :title => post[:title],
                                                :post => post,
                                                :previous => i < posts.length - 1 && posts[i + 1],
                                                :next => i > 0 && posts[i - 1],
                                                :filename => post[:filename],
                                                :comments => post[:comments]
                                              })
      File.open(File.join(@dest, post[:filename]), 'w') {|f| f.puts(post[:html]) }
    end
  end

  def generate_posts_json
    json = JSON.generate({ :published => posts.map {|p| p[:filename]} })
    File.open(File.join(@dest, 'posts.json'), 'w') { |f| f.puts(json) }
  end

  def generate_rss
    File.open(rss_file, 'w') { |f| f.puts(rss.target!) }
  end

  def posts
    prefix = File.join(@src, 'published') + '/'
    @posts ||= Dir[File.join(prefix, '*')].sort.reverse.map do |filename|
      lines = File.readlines(filename)
      post = { :filename => filename.sub(prefix, '') }
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
      post[:rfc822] = Time.parse(post[:date]).rfc822
      post[:url] = @url + '/' + post[:filename]
      # comments on by default
      post[:comments] = true if post[:comments].nil?
      post
    end
  end

  def rss
    template = File.read(File.join('templates', 'blog', 'post.rss.html'))
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version => '1.0'
    xml.instruct! 'xml-stylesheet', :href => 'http://samhuri.net/assets/blog.css', :type => 'text/css'
    xml.rss :version => '2.0' do
      xml.channel do
        xml.title @title
        xml.description @subtitle
        xml.link @url
        xml.pubDate @posts.first[:rfc822]

        posts.each do |post|
          xml.item do
            xml.title post[:title]
            xml.description Mustache.render(template, {:post => post})
            xml.pubDate post[:rfc822]
            xml.author post[:author]
            xml.link post[:url]
            xml.guid post[:url]
          end
        end
      end
    end
    xml
  end

  private

  def blog_file
    File.join(@src, 'blog.json')
  end

  def read_blog
    blog = JSON.parse(File.read(blog_file))
    @title = blog['title']
    @subtitle = blog['subtitle']
    @url = blog['url']
  end

  def rss_file
    File.join(@dest, 'sjs.rss')
  end

end

main if $0 == __FILE__
