#!/usr/bin/env ruby
# encoding: utf-8

require 'time'
require 'rubygems'
require 'bundler/setup'
require 'builder'
require 'json'
require 'rdiscount'
require 'mustache'

def main
  dir = ARGV.shift.to_s
  unless File.directory? dir
    puts 'usage: rss.rb <dir>'
    exit 1
  end
  b = Blag.new dir
  b.generate!
end

class Blag

  def self.go! dir
    self.new(dir).generate!
  end

  def initialize dir
    @dir = dir
  end

  def generate!
    generate_latest_post_json
    generate_rss
  end

  def generate_latest_post_json
    post = latest_post
    data['latest'] = {
      title: post['title'],
      date: post['date'],
      timestamp: post['timestamp'],
      tags: post['tags'],
      author: post['author'],
      url: post['relative_url'],
      link: post['link'],
      styles: post['styles'],
      body: post['body']
    }.delete_if { |k, v| v.nil? }
    json = JSON.pretty_generate data
    File.open(data_file, 'w') { |f| f.puts json }
  end

  def generate_rss
    File.open(rss_file, 'w') { |f| f.puts feed_xml.target! }
  end

  def latest_post
    posts.first
  end

  def posts
    @posts ||= begin
      prefix = @dir + '/posts/'
      json = File.read File.join(prefix, '_data.json')
      data = JSON.parse json
      data.map do |slug, post|
        filename = File.join prefix, slug + '.md'
        content = File.read filename
        post['slug'] = slug
        post['type'] = post['link'] ? :link : :post
        post['title'] += " →" if post['type'] == :link
        post['relative_url'] = '/posts/' + slug
        post['url'] = root_url + post['relative_url']
        post['content'] = content
        post['body'] = RDiscount.new(post['content'], :smart).to_html
        post['rfc822'] = Time.at(post['timestamp']).rfc822
        post
      end.sort_by { |p| -p['timestamp'] }.first(10)
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
    File.join @dir, 'feed.xml'
  end

  def rss_html post
    Mustache.render rss_template(post['type']), post: post
  end

  def feed_xml
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, version: '1.0'
    xml.instruct! 'xml-stylesheet', href: 'http://samhuri.net/css/style.css', type: 'text/css'

    xml.rss version: '2.0' do
      xml.channel do
        xml.title title
        xml.description subtitle
        xml.link root_url
        xml.pubDate posts.first['rfc822']

        posts.each do |post|
          xml.item do
            xml.title post['title']
            xml.description rss_html(post)
            xml.pubDate post['rfc822']
            xml.author post['author']
            xml.link post['link'] || post['url']
            xml.guid post['url']
          end
        end
      end
    end
    xml
  end

end

main if $0 == __FILE__