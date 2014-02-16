#!/usr/bin/env ruby
# encoding: utf-8

require 'time'
require 'rubygems'
require 'bundler/setup'
require 'builder'
require 'json'
require 'rdiscount'
require 'mustache'

DEFAULT_KEYWORDS = %w[samsonjs sjs sami samhuri sami samhuri samhuri.net]

def main
  srcdir = ARGV.shift.to_s
  destdir = ARGV.shift.to_s
  Dir.mkdir(destdir) unless File.exists?(destdir)
  unless File.directory? srcdir
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
    generate_posts_json
    generate_rss
  end

  def generate_posts_json
    posts_data = posts.reverse.inject({}) do |all, p|
      all[p[:slug]] = {
        title: p[:title],
        date: p[:date],
        timestamp: p[:timestamp],
        tags: p[:tags],
        author: p[:author],
        url: p[:relative_url],
        link: p[:link],
        styles: p[:styles]
      }.delete_if { |k, v| v.nil? }

      all
    end
    json = JSON.pretty_generate posts_data
    filename = File.join @dest, 'posts', '_data.json'
    File.open(filename, 'w') { |f| f.puts json }

    filename = File.join @dest, '_data.json'
    data = JSON.parse File.read(filename)
    post = latest_post
    data['latest'] = posts_data[post[:slug]].merge('body' => post[:body])
    json = JSON.pretty_generate data
    File.open(filename, 'w') { |f| f.puts json }
  end

  def generate_rss
    # posts rss
    File.open(rss_file, 'w') { |f| f.puts rss_for_posts.target! }
  end

  def latest_post
    posts.first
  end

  def posts
    prefix = @src + '/posts/'
    @posts ||= Dir[File.join(prefix, '*')].sort.reverse.map do |filename|
      next if File.directory?(filename) || filename =~ /_data\.json/

      lines = File.readlines filename
      post = {
        slug: filename.sub(prefix, '').sub(/\.(html|md)$/i, '')
      }
      loop do
        line = lines.shift.strip
        m = line.match /^(\w+):/
        if m && param = m[1].downcase
          post[param.to_sym] = line.sub(Regexp.new('^' + param + ':\s*', 'i'), '').strip
        elsif line.match /^----\s*$/
          lines.shift while lines.first.strip.empty?
          break
        else
          puts "ignoring unknown header: #{line}"
        end
      end
      if post[:styles]
        post[:styles] = post[:styles].split(/\s*,\s*/)
      end
      post[:type] = post[:link] ? :link : :post
      post[:title] += " →" if post[:type] == :link
      post[:tags] = (post[:tags] || '').split(/\s*,\s*/)
      post[:relative_url] = '/posts/' + post[:slug]
      post[:url] = @url + post[:relative_url]
      post[:timestamp] = post[:timestamp].to_i
      post[:content] = lines.join
      post[:body] = RDiscount.new(post[:content], :smart).to_html
      post[:rfc822] = Time.at(post[:timestamp]).rfc822
      post
    end.compact.sort { |a, b| b[:timestamp] <=> a[:timestamp] }
  end


  private

  def blog_file
    File.join(@src, '_data.json')
  end

  def read_blog
    blog = JSON.parse(File.read(blog_file))
    @title = blog['title']
    @subtitle = blog['subtitle']
    @url = blog['url']
  end

  def rss_template(type)
    if type == :post
      @post_rss_template ||= File.read(File.join('templates', 'post.rss.html'))
    elsif type == :link
      @link_rss_template ||= File.read(File.join('templates', 'link.rss.html'))
    else
      raise 'unknown post type: ' + type
    end
  end

  def rss_file
    File.join @dest, 'sjs.rss'
  end

  def rss_html post
    Mustache.render rss_template(post[:type]), post: post
  end

  def rss_for_posts options = {}
    title = options[:title] || @title
    subtitle = options[:subtitle] || @subtitle
    url = options[:url] || @url
    rss_posts ||= options[:posts] || posts[0, 10]

    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version => '1.0'
    xml.instruct! 'xml-stylesheet', :href => 'http://samhuri.net/css/style.css', :type => 'text/css'

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

end

main if $0 == __FILE__
