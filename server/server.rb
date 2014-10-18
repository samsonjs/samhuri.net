#!/usr/bin/env ruby -w

# An HTTP interface for my Harp blog.

require 'json'
require 'optparse'
require 'sinatra'
require './auth'
require './harp_blog'

$config = {
  auth: false,
  dry_run: false,
  path: File.expand_path('../test-blog', __FILE__),
  host: '127.0.0.1',
  port: 6706,
}

OptionParser.new do |opts|
  opts.banner = "Usage: server.rb [options]"

  opts.on("-a", "--[no-]auth", "Enable authentication") do |auth|
    $config[:auth] = auth
  end

  opts.on("-h", "--host [HOST]", "Host to bind") do |host|
    $config[:host] = host
  end

  opts.on("-p", "--port [PORT]", "Port to bind") do |port|
    $config[:port] = port.to_i
  end

  opts.on("-P", "--path [PATH]", "Path to Harp blog") do |path|
    $config[:path] = path
  end
end.parse!

unless File.exist?($config[:path])
  raise RuntimeError.new("file not found: #{$config[:path]}")
end

if $config[:host] == '0.0.0.0' && !$config[:auth]
  raise RuntimeError.new("cowardly refusing to bind to 0.0.0.0 without authentication")
end

$auth = Auth.new(File.expand_path('../auth.json', __FILE__))
def authenticated?(auth)
  if $config[:auth]
    username, password = auth.split('|')
    $auth.authenticated?(username, password)
  else
    true
  end
end

real_host = $config[:host] == '0.0.0.0' ? 'h.samhuri.net' : $config[:host]
$url_root = "http://#{real_host}:#{$config[:port]}/"
def url_for(*components)
  File.join($url_root, *components)
end

# Server

set :host, $config[:host]
set :port, $config[:port]

blog = HarpBlog.new($config[:path], $config[:dry_run])

# status
get '/status' do
  status 200
  headers 'Content-Type' => 'application/json'
  JSON.generate(blog.status)
end

# list years
get '/years' do
  unless authenticated?(request['Auth'])
    status 403
    return 'forbidden'
  end

  JSON.generate(years: blog.years)
end

# list months
get '/months' do
  unless authenticated?(request['Auth'])
    status 403
    return 'forbidden'
  end

  JSON.generate(months: blog.months)
end

# list posts
get '/posts/:year/?:month?' do |year, month|
  unless authenticated?(request['Auth'])
    status 403
    return 'forbidden'
  end

  posts =
    if month
      blog.posts_for_month(year, month)
    else
      blog.posts_for_year(year)
    end
  JSON.generate(posts: posts.map(&:fields))
end

# get a post
get '/posts/:year/:month/:slug' do |year, month, slug|
  unless authenticated?(request['Auth'])
    status 403
    return 'forbidden'
  end

  begin
    post = blog.get_post(year, month, slug)
  rescue HarpBlog::InvalidDataError => e
    status 500
    return "Failed to get post, invalid data on disk: #{e.message}"
  end

  if post
    if request.accept?('application/json')
      status 200
      headers 'Content-Type' => 'application/json'
      JSON.generate(post: post.fields)
    elsif request.accept?('text/html')
      status 200
      headers 'Content-Type' => 'text/html'
      blog.render_post(post.fields)
    else
      status 400
      "content not available in an acceptable format: #{request.accept.join(', ')}"
    end
  else
    status 404
    'not found'
  end
end

# make a post
post '/posts' do
  unless authenticated?(request['Auth'])
    status 403
    return 'forbidden'
  end

  begin
    post = blog.create_post(params[:title], params[:body], params[:link])
  rescue HarpBlog::PostExistsError => e
    post = HarpBlog::Post.new({
      title: params[:title],
      body: params[:body],
      link: params[:link],
    })
    status 409
    return  "refusing to clobber existing post, update it instead: #{post.url}"
  rescue HarpBlog::PostSaveError => e
    status 500
    if orig_err = e.original_error
      "#{e.message} -- #{orig_err.class}: #{orig_err.message}"
    else
      "Failed to create post: #{e.message}"
    end
  end

  if post
    url = url_for(post.url)
    status 201
    headers 'Location' => url, 'Content-Type' => 'application/json'
    JSON.generate(post: post.fields)
  else
    status 500
    'failed to create post'
  end
end

# update a post
put '/posts/:year/:month/:slug' do |year, month, slug|
  unless authenticated?(request['Auth'])
    status 403
    return 'forbidden'
  end

  begin
    if post = blog.get_post(year, month, slug)
      blog.update_post(post, params[:title], params[:body], params[:link])
      status 204
    else
      status 404
      'not found'
    end
  rescue HarpBlog::InvalidDataError => e
    status 500
    "Failed to update post, invalid data on disk: #{e.message}"
  rescue HarpBlog::PostSaveError => e
    status 500
    if orig_err = e.original_error
      "#{e.message} -- #{orig_err.class}: #{orig_err.message}"
    else
      "Failed to create post: #{e.message}"
    end
  end
end

# delete a post
delete '/posts/:year/:month/:slug' do |year, month, slug|
  unless authenticated?(request['Auth'])
    status 403
    return 'forbidden'
  end

  blog.delete_post(year, month, slug)
  status 204
end

# publish
post '/publish' do
  unless authenticated?(request['Auth'])
    status 403
    return 'forbidden'
  end

  production = params[:env] == 'production'
  blog.publish(production)
  status 204
end
