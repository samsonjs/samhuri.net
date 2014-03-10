#!/usr/bin/env ruby -w

# MetaWeblog and Blogger API to post to this site.

require 'xmlrpc/server'
require 'xmlrpc/client'
require './meta_weblog_handler'

def main
  port = (ARGV.shift || 6706).to_i
  server = XMLRPC::Server.new(port, '0.0.0.0')
  server.add_handler('metaWeblog', MetaWeblogHandler.new)
  server.serve
end

main if $0 == __FILE__
