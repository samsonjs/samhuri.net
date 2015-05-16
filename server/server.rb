#!/usr/bin/env ruby -w

# An HTTP interface for my Harp blog.

require 'json'
require 'sinatra'
require './auth'
require './harp_blog'

CONFIG_DEFAULTS = {
  auth: false,
  dry_run: false,
  path: File.expand_path('../test-blog', __FILE__),
  host: '127.0.0.1',
  hostname: `hostname --fqdn`.strip,
  port: 6706,
  preview_port: 5000,
}

def env_value(name)
  env_name = "BLOG_#{name.to_s.upcase}"
  raw_value = ENV[env_name]
  case name
  when :auth, :dry_run
    raw_value ? raw_value.to_i != 0 : false
  when :port
    raw_value ? raw_value.to_i : nil
  else
    raw_value
  end
end

$config = CONFIG_DEFAULTS.dup
$config.each_key do |name|
  value = env_value(name)
  unless value.nil?
    $config[name] = value
  end
end

$config[:preview_url] = "http://#{$config[:hostname]}:#{$config[:preview_port]}"

unless File.directory?($config[:path])
  raise RuntimeError.new("file not found: #{$config[:path]}")
end

if $config[:host] == '0.0.0.0' && !$config[:auth]
  raise RuntimeError.new("cowardly refusing to bind to 0.0.0.0 without authentication")
end

$auth = Auth.new(File.expand_path('../auth.json', __FILE__))
def authenticated?(auth)
  if $config[:auth]
    username, password = auth.to_s.split('|')
    $auth.authenticated?(username, password)
  else
    true
  end
end

host = $config[:hostname] || $config[:host]
$url_root = "http://#{host}:#{$config[:port]}/"
puts "URL root: #{$url_root}"
def url_for(*components)
  File.join($url_root, *components)
end

# Server

set :host, $config[:host]
set :port, $config[:port]

blog = HarpBlog.new($config[:path], $config[:dry_run])

before do
  if request.body.size > 0
    @fields =
      case
      when request.accept?('application/json')
        request.body.rewind
        json = request.body.read
        JSON.parse(json)
      else
        params
      end
  else
    @fields = {}
  end
  @wait_for_compilation = @fields['wait']
end

after do
  compile = -> {
    start = Time.now
    if blog.compile_if_mutated
      duration = Time.now.to_f - start.to_f
      puts "Compiled blog in #{duration.round(2)}s"
    end
  }
  if @wait_for_compilation
    compile.call
  else
    fork(&compile)
  end
end

# favicon
get '/favicon.ico' do
  status 302
  headers 'Location' => "#{$config[:preview_url]}/favicon.ico"
end

# status
get '/status' do
  status 200
  headers 'Content-Type' => 'application/json'
  JSON.generate(status: blog.status)
end

# publish the site
post '/publish' do
  unless authenticated?(request.env['HTTP_AUTH'])
    status 403
    return 'forbidden'
  end

  blog.publish(@fields['env'])
  status 204
end

# sync with github
post '/sync' do
  unless authenticated?(request.env['HTTP_AUTH'])
    status 403
    return 'forbidden'
  end

  blog.sync
  status 204
  nil
end

# list years
get '/years' do
  status 200
  headers 'Content-Type' => 'application/json'
  JSON.generate(years: blog.years)
end

# list months
get '/months' do
  status 200
  headers 'Content-Type' => 'application/json'
  JSON.generate(months: blog.months)
end


##############
### Drafts ###
##############

# list drafts
get '/posts/drafts' do
  posts = blog.drafts

  status 200
  headers 'Content-Type' => 'application/json'
  JSON.generate(posts: posts.map(&:fields))
end

# get a draft
get '/posts/drafts/:id' do |id|
  begin
    post = blog.get_draft(id)
  rescue HarpBlog::InvalidDataError => e
    status 500
    return "Failed to get draft, invalid data on disk: #{e.message}"
  end

  if post
    if request.accept?('text/html')
      status 302
      headers 'Location' => "#{$config[:preview_url]}/posts/drafts/#{id}"
      nil
    elsif request.accept?('application/json')
      status 200
      headers 'Content-Type' => 'application/json'
      JSON.generate(post: post.fields)
    else
      status 400
      "content not available in an acceptable format: #{request.accept.join(', ')}"
    end
  else
    status 404
    'not found'
  end
end

# make a draft, and optionally publish it immediately
post '/posts/drafts' do
  unless authenticated?(request.env['HTTP_AUTH'])
    status 403
    return 'forbidden'
  end

  id, title, body, link = @fields.values_at('id', 'title', 'body', 'link')
  begin
    if post = blog.create_post(title, body, link, id: id, draft: true)
      if @fields['env']
        post = blog.publish_post(post)
        fork do
          blog.publish(@fields['env'])
        end
        @wait_for_compilation = false
      end
      url = url_for(post.url)
      status 201
      headers 'Location' => url, 'Content-Type' => 'application/json'
      JSON.generate(post: post.fields)
    else
      status 500
      'failed to create post'
    end
  rescue HarpBlog::PostExistsError => e
    post = HarpBlog::Post.new({
      title: title,
      body: body,
      link: link,
    })
    status 409
    "refusing to clobber existing draft, update it instead: #{post.url}"
  rescue HarpBlog::PostSaveError => e
    status 500
    if orig_err = e.original_error
      "#{e.message} -- #{orig_err.class}: #{orig_err.message}"
    else
      "Failed to create draft: #{e.message}"
    end
  end
end

# update a draft
put '/posts/drafts/:id' do |id|
  unless authenticated?(request.env['HTTP_AUTH'])
    status 403
    return 'forbidden'
  end

  title, body, link = @fields.values_at('title', 'body', 'link')
  begin
    if post = blog.get_draft(id)
      blog.update_post(post, title, body, link, Time.now.to_i)
      status 204
    else
      status 404
      'not found'
    end
  rescue HarpBlog::InvalidDataError => e
    status 500
    "Failed to update draft, invalid data on disk: #{e.message}"
  rescue HarpBlog::PostSaveError => e
    status 500
    if orig_err = e.original_error
      "#{e.message} -- #{orig_err.class}: #{orig_err.message}"
    else
      "Failed to update draft: #{e.message}"
    end
  end
end

# delete a draft
delete '/posts/drafts/:id' do |id|
  unless authenticated?(request.env['HTTP_AUTH'])
    status 403
    return 'forbidden'
  end

  blog.delete_draft(id)
  status 204
end

# publish a post
post '/posts/drafts/:id/publish' do |id|
  unless authenticated?(request.env['HTTP_AUTH'])
    status 403
    return 'forbidden'
  end

  if post = blog.get_draft(id)
    new_post = blog.publish_post(post)
    @wait_for_compilation = true
    status 201
    headers 'Location' => url_for(new_post.url), 'Content-Type' => 'application/json'
    JSON.generate(post: new_post.fields)
  else
    status 404
    'not found'
  end
end


#######################
### Published Posts ###
#######################

# list published posts
get '/posts/:year/?:month?' do |year, month|
  posts =
    if month
      blog.posts_for_month(year, month)
    else
      blog.posts_for_year(year)
    end

  status 200
  headers 'Content-Type' => 'application/json'
  JSON.generate(posts: posts.map(&:fields))
end

# list all published posts
get '/posts' do
  posts = blog.months.map do |year, month|
    blog.posts_for_month(year, month)
  end.flatten.reverse

  status 200
  headers 'Content-Type' => 'application/json'
  JSON.generate(posts: posts.map(&:fields))
end

# get a post
get '/posts/:year/:month/:id' do |year, month, id|
  begin
    post = blog.get_post(year, month, id)
  rescue HarpBlog::InvalidDataError => e
    status 500
    return "Failed to get post, invalid data on disk: #{e.message}"
  end

  if post
    if request.accept?('text/html')
      status 302
      headers 'Location'=> "#{$config[:preview_url]}/posts/#{year}/#{month}/#{id}"
      nil
    elsif request.accept?('application/json')
      status 200
      headers 'Content-Type' => 'application/json'
      JSON.generate(post: post.fields)
    else
      status 400
      "content not available in an acceptable format: #{request.accept.join(', ')}"
    end
  else
    status 404
    'not found'
  end
end

# update a post
put '/posts/:year/:month/:id' do |year, month, id|
  unless authenticated?(request.env['HTTP_AUTH'])
    status 403
    return 'forbidden'
  end

  title, body, link = @fields.values_at('title', 'body', 'link')
  begin
    if post = blog.get_post(year, month, id)
      blog.update_post(post, title, body, link)
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
      "Failed to update post: #{e.message}"
    end
  end
end

# delete a post
delete '/posts/:year/:month/:id' do |year, month, id|
  unless authenticated?(request.env['HTTP_AUTH'])
    status 403
    return 'forbidden'
  end

  blog.delete_post(year, month, id)
  status 204
end

# unpublish a post
post '/posts/:year/:month/:id/unpublish' do |year, month, id|
  unless authenticated?(request.env['HTTP_AUTH'])
    status 403
    return 'forbidden'
  end

  if post = blog.get_post(year, month, id)
    new_post = blog.unpublish_post(post)
    @wait_for_compilation = true
    status 200
    headers 'Location' => url_for(new_post.url), 'Content-Type' => 'application/json'
    JSON.generate(post: new_post.fields)
  else
    status 404
    'not found'
  end
end
