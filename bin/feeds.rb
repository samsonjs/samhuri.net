#!/usr/bin/env ruby -w
# encoding: utf-8

require 'rubygems'
require 'time'
require 'bundler/setup'
require 'builder'
require 'json'
require 'rdiscount'
require 'mustache'

class Hash
  def compact
    h = {}
    each_pair do |k, v|
      h[k] = v unless v.nil?
    end
    h
  end
end

def main
  dir = ARGV.shift.to_s
  unless File.directory? dir
    puts 'usage: feeds.rb <dir>'
    exit 1
  end
  b = Blag.new dir
  b.generate!
end

class Blag

  def self.go! dir
    self.new(dir).generate!
  end

  def initialize dir, index_posts = 10, feed_posts = 30
    @dir = dir
    @index_posts = index_posts
    @feed_posts = feed_posts
  end

  def generate!
    generate_latest_posts_json
    generate_rss
    generate_json_feed
  end

  def generate_latest_posts_json
    data['posts'] = latest_posts(@index_posts).map do |post|
      {
        title: post['title'],
        date: post['date'],
        timestamp: post['timestamp'],
        tags: post['tags'],
        author: post['author'],
        url: post['relative_url'],
        link: post['link'],
        styles: post['styles']
      }.delete_if { |k, v| v.nil? }
    end
    json = JSON.pretty_generate data
    File.write(data_file, json)
  end

  def generate_rss
    File.write(rss_file, feed_xml.target!)
  end

  def generate_json_feed
    File.write(json_feed_file, feed_json)
  end

  def latest_posts(n)
    posts.first(n)
  end

  def find_post dir, slug
    # technically should look for slug.md, slug.html.md, etc.
    File.join dir, slug + '.md'
  end

  def posts
    @posts ||= begin
      Dir[File.join(@dir, 'posts/20*/*')].map do |dir|
        next unless dir =~ /\/\d\d$/
        json = File.read File.join(dir, '_data.json')
        data = JSON.parse json
        prefix = dir.sub(@dir, '')
        data.map do |slug, post|
          filename = find_post dir, slug
          content = File.read filename
          relative_url = File.join(prefix, slug)
          post['slug'] = slug
          post['type'] = post['link'] ? :link : :post
          post['title'] = "→ #{post['title']}" if post['type'] == :link
          post['relative_url'] = relative_url
          post['url'] = root_url + post['relative_url']
          post['external_url']
          post['content'] = content
          post['body'] = RDiscount.new(content, :smart).to_html
          post['time'] = Time.at(post['timestamp'])
          post
        end
      end.flatten.compact.sort_by { |p| -p['timestamp'] }
    end
  end

  def title
    data['title']
  end

  def subtitle
    data['subtitle']
  end

  def root_url
    data['url']
  end


private

  def data_file
    File.join @dir, '_data.json'
  end

  def data
    @data ||= JSON.parse File.read(data_file)
  end

  def feed_template(type)
    if type == :post
      @post_rss_template ||= File.read(File.join('templates', 'post.feed.html'))
    elsif type == :link
      @link_rss_template ||= File.read(File.join('templates', 'link.feed.html'))
    else
      raise 'unknown post type: ' + type
    end
  end

  def rss_file
    File.join @dir, 'feed.xml'
  end

  def feed_html post
    html = Mustache.render feed_template(post['type']), post: post
    # this is pretty disgusting
    html.gsub 'src="/', "src=\"#{root_url}/"
  end

  def feed_xml
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, version: '1.0'
    xml.instruct! 'xml-stylesheet', href: root_url + '/css/normalize.css', type: 'text/css'
    xml.instruct! 'xml-stylesheet', href: root_url + '/css/style.css', type: 'text/css'

    xml.rss version: '2.0' do
      xml.channel do
        xml.title title
        xml.description subtitle
        xml.link root_url
        xml.pubDate posts.first['time'].rfc822

        latest_posts(@feed_posts).each do |post|
          xml.item do
            xml.title post['title']
            xml.description feed_html(post)
            xml.pubDate post['time'].rfc822
            xml.author post['author']
            xml.link post['link'] || post['url']
            xml.guid post['url']
          end
        end
      end
    end
    xml
  end

  def json_feed_file
    File.join @dir, 'feed.json'
  end

  def feed_json
    JSON.pretty_generate(build_json_feed)
  end

  def build_json_feed
    {
      version: "https://jsonfeed.org/version/1",
      title: title,
      home_page_url: root_url,
      feed_url: "#{root_url}/feed.json",
        author: {
          url: "https://samhuri.net",
          name: "Sami J. Samhuri",
          avatar: "#{root_url}/images/me.jpg"
      },
      icon: "#{root_url}/images/apple-touch-icon-300.png",
      favicon: "#{root_url}/images/apple-touch-icon-80.png",
      items: latest_posts(@feed_posts).map do |post|
        {
          title: post['title'],
          date_published: post['time'].to_datetime.rfc3339,
          id: post['url'],
          url: post['url'],
          external_url: post['link'],
          author: {
            name: post['author']
          },
          content_html: feed_html(post),
          tags: post['tags']
        }.compact
      end
    }
  end

end

main if $0 == __FILE__