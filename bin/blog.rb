#!/usr/bin/env ruby
# encoding: utf-8

require 'time'
require 'rubygems'
require 'bundler/setup'
require 'builder'
require 'json'
require 'mustache'
require 'rdiscount'

DefaultKeywords = ['sjs', 'sami samhuri', 'sami', 'samhuri', 'samhuri.net', 'blog']

ShortURLCodeSet = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
ShortURLBase = ShortURLCodeSet.length.to_f

def main
  srcdir = ARGV.shift.to_s
  destdir = ARGV.shift.to_s
  Dir.mkdir(destdir) unless File.exists?(destdir)
  unless File.directory?(srcdir)
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
    @blog_dest = File.join(dest, 'blog')
    @css_dest = File.join(dest, 'css')
    read_blog
  end

  def generate!
    generate_posts
    generate_index
    generate_rss
    generate_posts_json
    generate_archive
    generate_short_urls
    copy_assets
  end

  def generate_index
    # generate landing page
    index_template = File.read(File.join('templates', 'blog', 'index.html'))
    post = posts.first
    values = { :post => post,
               :styles => post[:styles],
               :article => html(post),
               :previous => posts[1],
               :filename => post[:filename],
               :comments => post[:comments]
             }
    index_html = Mustache.render(index_template, values)
    File.open(File.join(@blog_dest, 'index.html'), 'w') {|f| f.puts(index_html) }
  end

  def generate_posts
    page_template = File.read(File.join('templates', 'blog', 'post.html'))
    posts.each_with_index do |post, i|
      puts "comments: #{post[:comments].inspect}"
      values = { :title => post[:title],
                 :link => post[:link],
                 :styles => post[:styles],
                 :article => html(post),
                 :previous => i < posts.length - 1 && posts[i + 1],
                 :next => i > 0 && posts[i - 1],
                 :filename => post[:filename],
                 :comments => post[:comments],
                 :keywords => (DefaultKeywords + post[:tags]).join(',')
               }
      post[:html] = Mustache.render(page_template, values)
      File.open(File.join(@blog_dest, post[:filename]), 'w') {|f| f.puts(post[:html]) }
    end
  end

  def generate_posts_json
    json = JSON.generate({ :published => posts.map {|p| p[:filename]} })
    File.open(File.join(@blog_dest, 'posts.json'), 'w') { |f| f.puts(json) }
  end

  def generate_archive
    archive_template = File.read(File.join('templates', 'blog', 'archive.html'))
    html = Mustache.render(archive_template, :posts => posts)
    File.open(File.join(@blog_dest, 'archive.html'), 'w') { |f| f.puts(html) }
  end

  def generate_rss
    # posts rss
    File.open(rss_file, 'w') { |f| f.puts(rss_for_posts.target!) }
  end

  def generate_short_urls
    htaccess = ['RewriteEngine on', 'RewriteRule ^$ http://samhuri.net [R=301,L]']
    posts.reverse.each_with_index do |post, i|
      code = shorten(i + 1)
      htaccess << "RewriteRule ^#{code}$ #{post[:url]} [R=301,L]"
    end
    File.open(File.join(@dest, 's42', '.htaccess'), 'w') do |f|
      f.puts(htaccess)
    end
  end

  def copy_assets
    Dir[File.join(@src, 'css', '*.css')].each do |stylesheet|
      minified = File.join(@css_dest, File.basename(stylesheet).sub('.css', '.min.css'))
      `yui-compressor #{stylesheet} #{minified}`
    end
    Dir[File.join(@src, 'files', '*')].each do |file|
      FileUtils.copy(file, File.join(@dest, 'f', File.basename(file)))
    end
    Dir[File.join(@src, 'images', '*')].each do |file|
      FileUtils.copy(file, File.join(@dest, 'images', 'blog', File.basename(file)))
    end
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
      post[:type] = post[:link] ? :link : :post
      post[:title] += " →" if post[:type] == :link
      post[:styles] = (post[:styles] || '').split(/\s*,\s*/)
      post[:tags] = (post[:tags] || '').split(/\s*,\s*/)
      post[:url] = @url + '/' + post[:filename]
      post[:timestamp] = post[:timestamp].to_i
      post[:content] = lines.join
      post[:body] = RDiscount.new(post[:content], :smart).to_html
      post[:rfc822] = Time.at(post[:timestamp]).rfc822
      # comments on by default
      post[:comments] = (post[:comments] == 'on' || post[:comments].nil?)
      post
    end.sort { |a, b| b[:timestamp] <=> a[:timestamp] }
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

  def html(post)
    Mustache.render(template(post[:type]), post)
  end

  def template(type)
    if type == :post
      @post_template ||= File.read(File.join('templates', 'blog', 'post.mustache'))
    elsif type == :link
      @link_template ||= File.read(File.join('templates', 'blog', 'link.mustache'))
    else
      raise 'unknown post type: ' + type
    end
  end

  def rss_template(type)
    if type == :post
      @post_rss_template ||= File.read(File.join('templates', 'blog', 'post.rss.html'))
    elsif type == :link
      @link_rss_template ||= File.read(File.join('templates', 'blog', 'link.rss.html'))
    else
      raise 'unknown post type: ' + type
    end
  end

  def rss_file
    File.join(@blog_dest, 'sjs.rss')
  end

  def rss_html(post)
    Mustache.render(rss_template(post[:type]), { :post => post })
  end
  
  def rss_for_posts(options = {})
    title = options[:title] || @title
    subtitle = options[:subtitle] || @subtitle
    url = options[:url] || @url
    rss_posts ||= options[:posts] || posts[0, 10]

    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version => '1.0'
    xml.instruct! 'xml-stylesheet', :href => 'http://samhuri.net/css/blog-all.min.css', :type => 'text/css'

    rss_posts.each do |post|
      post[:styles].each do |style|
        xml.instruct! 'xml-stylesheet', :href => "http://samhuri.net/css/#{style}.min.css", :type => 'text/css'
      end
    end

    xml.rss :version => '2.0' do
      xml.channel do
        xml.title title
        xml.description subtitle
        xml.link url
        xml.pubDate posts.first[:rfc822]

        rss_posts.each do |post|
          xml.item do
            xml.title post[:title]
            xml.description rss_html(post)
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

  def shorten(n)
    short = ''
    while n > 0
      short = ShortURLCodeSet[n % ShortURLBase, 1] + short
      n = (n / ShortURLBase).floor
    end
    short
  end

end

main if $0 == __FILE__
