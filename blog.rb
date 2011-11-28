#!/usr/bin/env ruby

require 'time'
require 'rubygems'
require 'bundler/setup'
require 'builder'
require 'json'
require 'mustache'
require 'rdiscount'

DefaultKeywords = ['sjs', 'sami samhuri', 'sami', 'samhuri', 'samhuri.net', 'blog']

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
    generate_archive
  end

  def generate_index
    # generate landing page
    index_template = File.read(File.join('templates', 'blog', 'index.html'))
    post = posts.first
    template = post[:link] ? link_template : post_template
    values = { :post => post,
               :article => Mustache.render(template, post),
               :previous => posts[1],
               :filename => post[:filename],
               :comments => post[:comments]
             }
    index_html = Mustache.render(index_template, values)
    File.open(File.join(@dest, 'index.html'), 'w') {|f| f.puts(index_html) }
  end

  def generate_posts
    page_template = File.read(File.join('templates', 'blog', 'post.html'))
    posts.each_with_index do |post, i|
      template = post[:link] ? link_template : post_template
      values = { :title => post[:title],
                 :link => post[:link],
                 :article => Mustache.render(template, post),
                 :previous => i < posts.length - 1 && posts[i + 1],
                 :next => i > 0 && posts[i - 1],
                 :filename => post[:filename],
                 :comments => post[:comments],
                 :keywords => (DefaultKeywords + post[:tags]).join(',')
               }
      post[:html] = Mustache.render(page_template, values)
      File.open(File.join(@dest, post[:filename]), 'w') {|f| f.puts(post[:html]) }
    end
  end

  def generate_posts_json
    json = JSON.generate({ :published => posts.map {|p| p[:filename]} })
    File.open(File.join(@dest, 'posts.json'), 'w') { |f| f.puts(json) }
  end

  def generate_archive
    archive_template = File.read(File.join('templates', 'blog', 'archive.html'))
    html = Mustache.render(archive_template, :posts => posts)
    File.open(File.join(@dest, 'archive.html'), 'w') { |f| f.puts(html) }
  end

  def generate_rss
    # posts rss
    File.open(rss_file, 'w') { |f| f.puts(rss.target!) }
  end

  def posts
    prefix = File.join(@src, 'published') + '/'
    @posts ||= Dir[File.join(prefix, '*')].sort.reverse.map do |filename|
      lines = File.readlines(filename)
      post = { :filename => filename.sub(prefix, '').sub(/\.m(ark)?d(own)?$/i, '.html') }
      loop do
        line = lines.shift.strip
        m = line.match(/^(\w+):/)
        if m && param = m[1].downcase
          post[param.to_sym] = line.sub(Regexp.new('^' + param + ':\s*', 'i'), '').strip
        elsif line.match(/^----\s*$/)
          lines.shift while lines.first.strip.empty?
          break
        else
          puts "ignoring unknown header: #{line}"
        end
      end
      post[:url] = @url + '/' + post[:filename]
      post[:timestamp] = post[:timestamp].to_i
      post[:content] = lines.join
      template = post[:link] ? link_rss_template : post_rss_template
      post[:rss_html] = Mustache.render(template, {:post => post})
      post[:body] = RDiscount.new(post[:content]).to_html
      post[:rfc822] = Time.at(post[:timestamp]).rfc822
      post[:tags] = (post[:tags] || '').split(/\s*,\s*/).map(&:strip)
      # comments on by default
      post[:comments] = true if post[:comments].nil?
      post
    end.sort { |a, b| b[:timestamp] <=> a[:timestamp] }
  end

  def rss
    rss_for_posts
  end

  private

  def post_template
    @post_template ||= File.read(File.join('templates', 'blog', 'post.mustache'))
  end

  def link_template
    @link_template ||= File.read(File.join('templates', 'blog', 'link.mustache'))
  end

  def blog_file
    File.join(@src, 'blog.json')
  end

  def post_rss_template
     @post_rss_template ||= File.read(File.join('templates', 'blog', 'post.rss.html'))
  end

  def link_rss_template
     @link_rss_template ||= File.read(File.join('templates', 'blog', 'link.rss.html'))
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

  def rss_for_posts(options = {})
    title = options[:title] || @title
    subtitle = options[:subtitle] || @subtitle
    url = options[:url] || @url
    posts ||= options[:posts] || method(:posts).call

    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version => '1.0'
    xml.instruct! 'xml-stylesheet', :href => 'http://samhuri.net/assets/blog-all.min.css', :type => 'text/css'
    xml.rss :version => '2.0' do
      xml.channel do
        xml.title title
        xml.description subtitle
        xml.link url
        xml.pubDate posts.first[:rfc822]

        posts.each do |post|
          xml.item do
            xml.title post[:link] ? "&rarr; #{post[:title]}" : post[:title]
            xml.description post[:rss_html]
            xml.pubDate post[:rfc822]
            xml.author post[:author]
            xml.link post[:link] || post[:url]
            xml.guid post[:url]
          end
        end
      end
    end
    xml
  end

end

main if $0 == __FILE__
