#!/usr/bin/env ruby

require 'time'
require 'rubygems'
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
  puts "#{b.tag_names.size} tags"
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
    generate_tags
    generate_rss
    generate_posts_json
  end

  def generate_index
    # generate landing page
    index_template = File.read(File.join('templates', 'blog', 'index.html'))
    values = { :posts => posts,
               :post => posts.first,
               :article => Mustache.render(article_template, posts.first),
               :previous => posts[1],
               :filename => posts.first[:filename],
               :comments => posts.first[:comments]
             }
    index_html = Mustache.render(index_template, values)
    File.open(File.join(@dest, 'index.html'), 'w') {|f| f.puts(index_html) }
  end

  def generate_posts
    template = File.read(File.join('templates', 'blog', 'post.html'))
    posts.each_with_index do |post, i|
      values = { :title => post[:title],
                 :article => Mustache.render(article_template, post),
                 :previous => i < posts.length - 1 && posts[i + 1],
                 :next => i > 0 && posts[i - 1],
                 :filename => post[:filename],
                 :comments => post[:comments],
                 :keywords => (DefaultKeywords + post[:tags]).join(',')
               }
      post[:html] = Mustache.render(template, values)
      File.open(File.join(@dest, post[:filename]), 'w') {|f| f.puts(post[:html]) }
    end
  end

  def generate_posts_json
    json = JSON.generate({ :published => posts.map {|p| p[:filename]} })
    File.open(File.join(@dest, 'posts.json'), 'w') { |f| f.puts(json) }
  end

  def generate_rss
    # posts rss
    File.open(rss_file, 'w') { |f| f.puts(rss.target!) }

    # tags rss
    Dir.mkdir(tags_dir) unless File.exists?(tags_dir)
    tag_names.each do |tag|
      Dir.mkdir(tag_dir(tag)) unless File.exists?(tag_dir(tag))
      File.open(rss_tag_file(tag), 'w') { |f| f.puts(rss_for_tag(tag).target!) }
    end
  end

  def generate_tags
    Dir.mkdir(tags_dir) unless File.exists?(tags_dir)

    # tag index
    File.open(tag_index_file, 'w') do |f|
      groups = chunk(tag_names).map do |ns|
        { :tags => ns.map do |t|
            { :name => t }
          end
        }
      end
      values = { :tag_groups => groups }
      f.puts(Mustache.render(tags_template, values))
    end

    # tag pages
    tag_names.each do |tag|
      posts = tags[tag]
      Dir.mkdir(tag_dir(tag)) unless File.exists?(tag_dir(tag))
      File.open(tag_html_file(tag), 'w') do |f|
        f.puts(Mustache.render(tag_template, { :tag => tag, :posts => posts }))
      end
    end
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
      post[:rss_html] = Mustache.render(post_rss_template, {:post => post})
      post[:body] = RDiscount.new(post[:content]).to_html
      post[:rfc822] = Time.parse(post[:date]).rfc822
      post[:tags] = (post[:tags] || '').split(/\s*,\s*/).map(&:strip)
      post[:url] = @url + '/' + post[:filename]
      # comments on by default
      post[:comments] = true if post[:comments].nil?
      post
    end
  end

  def rss
    rss_for_posts
  end

  def rss_for_tag(tag)
    rss_for_posts :title => tag + ' :: ' + @title,
                  :subtitle => tag,
                  :url => tag_url(tag),
                  :posts => tags[tag]
  end

  def tag_names
    @tag_names ||= tags.keys.sort
  end

  def tags
    return @tags if @tags
    @tags = {}
    posts.each do |post|
      post[:tags].each do |tag|
        @tags[tag] ||= []
        @tags[tag] << post
      end
    end
    @tags
  end

  private

  def article_template
    @article_template ||= File.read(File.join('templates', 'blog', 'article.mustache'))
  end

  def blog_file
    File.join(@src, 'blog.json')
  end

  def post_rss_template
    @post_rss_template ||= File.read(File.join('templates', 'blog', 'post.rss.html'))
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
            xml.title post[:title]
            xml.description post[:rss_html]
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

  def rss_tag_file(tag)
    File.join(@dest, 'tags', tag, 'index.rss')
  end

  def rss_tags_file(tag)
    File.join(@dest, 'tags.rss')
  end

  def tag_dir(tag)
    File.join(@dest, 'tags', tag)
  end

  def tags_dir
    @tag_dir ||= File.join(@dest, 'tags')
  end

  def tag_html_file(tag)
    File.join(@dest, 'tags', tag, 'index.html')
  end

  def tag_index_file
    File.join(@dest, 'tags', 'index.html')
  end

  def tag_template
    @tag_template ||= File.read(File.join('templates', 'blog', 'tags', 'tag.html'))
  end

  def tags_template
    @tags_template ||= File.read(File.join('templates', 'blog', 'tags', 'index.html'))
  end

  def tag_url(tag)
    @url + '/tags/' + tag
  end

  def chunk(array, pieces=3)
    len = array.length;
    mid = (len/pieces)
    chunks = []
    start = 0
    1.upto(pieces) do |i|
      last = start+mid
      last = last-1 unless len%pieces >= i
      chunks << array[start..last] || []
      start = last+1
    end
    chunks
  end
  
end

main if $0 == __FILE__
