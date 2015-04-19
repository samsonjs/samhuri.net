#!/usr/bin/env ruby -w

require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'css_parser'

# Styles are so small, inline them all.

def main
  root_dir = ARGV.shift
  CSSInliner.new(root_dir).inline_all_css
end

class CSSInliner

  def initialize(root_dir)
    @root_dir = root_dir
  end

  def inline_all_css
    Dir[File.join(@root_dir, '**/*.html')].each do |html_path|
      next if html_path =~ /\/Chalk\/|\/tweets\//
      inline_css(html_path)
    end
  end

  def inline_css(html_path)
    html = File.read(html_path)
    doc = Nokogiri::HTML.parse(html)
    css_parser = CssParser::Parser.new

    doc.css('link').each do |link|
      if link['rel'] == 'stylesheet'
        path = File.join(@root_dir, link['href'])
        css = File.read(path)
        css_parser.add_block!(css)

        style_node = Nokogiri::HTML.parse("
          <style>
            #{css}
          </style>
        ").css('style')

        link.replace(style_node)
      end
    end

    File.write(html_path, doc.to_html)
  end

end

main if $0 == __FILE__
