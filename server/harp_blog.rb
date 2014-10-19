require 'fileutils'
require 'json'
require './web_title_finder'
require './web_version_finder'

class HarpBlog

  class HarpBlogError < RuntimeError ; end
  class InvalidDataError < HarpBlogError ; end
  class PostExistsError < HarpBlogError ; end
  class PostAlreadyPublishedError < HarpBlogError ; end
  class PostNotPublishedError < HarpBlogError ; end

  class PostSaveError < HarpBlogError
    attr_reader :original_error
    def initialize(message, original_error)
      super(message)
      @original_error = original_error
    end
  end

  class Post
    PERSISTENT_FIELDS = %w[author title date timestamp link url tags].map(&:to_sym)
    TRANSIENT_FIELDS = %w[time slug body draft].map(&:to_sym)
    FIELDS = PERSISTENT_FIELDS + TRANSIENT_FIELDS
    attr_accessor *FIELDS

    def initialize(fields = nil)
      if fields
        FIELDS.each do |k|
          if v = fields[k.to_s] || fields[k.to_sym]
            instance_variable_set("@#{k}", v)
          end
        end
      end
    end

    def persistent_fields
      PERSISTENT_FIELDS.inject({}) do |h, k|
        h[k] = send(k)
        h
      end
    end

    def fields
      FIELDS.inject({}) do |h, k|
        h[k] = send(k)
        h
      end
    end

    def link?
      !!link
    end

    def draft?
      @draft
    end

    def author
      @author ||= 'Sami Samhuri'
    end

    def time
      @time ||= @timestamp ? Time.at(@timestamp) : Time.now
    end

    def time=(time)
      @timestamp = nil
      @date = nil
      @url = nil
      @time = time
    end

    def timestamp
      @timestamp ||= time.to_i
    end

    def timestamp=(timestamp)
      @time = nil
      @date = nil
      @url = nil
      @timestamp = timestamp
    end

    def url
      @url ||=
        if draft?
          "/posts/drafts/#{slug}"
        else
          "/posts/#{time.year}/#{padded_month}/#{slug}"
        end
    end

    def slug
      # TODO: be intelligent about unicode ... \p{Word} might help. negated char class with it?
      if title
        @slug ||= title.downcase.
          gsub(/'/, '').
          gsub(/[^[:alpha:]\d_]/, '-').
          gsub(/^-+|-+$/, '').
          gsub(/-+/, '-')
      end
    end

    def date
      @date ||= time.strftime('%B %d, %Y')
    end

    def tags
      @tags ||= []
    end

    def padded_month
      pad(time.month)
    end

    def dir
      if draft?
        'drafts'
      else
        File.join(time.year.to_s, padded_month)
      end
    end

    def pad(n)
      n.to_i < 10 ? "0#{n}" : "#{n}"
    end
  end # Post


  def initialize(path, dry_run = true, title_finder = nil, version_finder = nil)
    @path = path
    @dry_run = dry_run
    @title_finder = title_finder || WebTitleFinder.new
    @version_finder = version_finder || WebVersionFinder.new
  end

  def local_version
    git_sha
  end

  def remote_version
    @version_finder.find_version
  end

  def dirty?
    local_version != remote_version
  end

  def status
    {
      'local-version' => local_version,
      'remote-version' => remote_version,
      'dirty' => dirty?,
    }
  end

  def years
    Dir[post_path('20*')].map { |x| File.basename(x) }.sort
  end

  def months
    years.map do |year|
      # hack: month dirs (and only month dirs) are always 2 characters in length
      Dir[post_path(year, '??')].map { |x| [year, File.basename(x)] }
    end.flatten(1).sort
  end

  def posts_for_year(year)
    posts = []
    1.upto(12) do |n|
      month = n < 10 ? "0#{n}" : "#{n}"
      posts += posts_for_month(year, month)
    end
    posts
  end

  def posts_for_month(year, month)
    read_posts(File.join(year, month))
  end

  def drafts
    read_posts('drafts', draft: true)
  end

  def get_post(year, month, slug)
    read_post(File.join(year, month), slug)
  end

  def get_draft(slug)
    read_post('drafts', slug, draft: true)
  end

  def create_post(title, body, link, extra_fields = nil)
    if !title || title.strip.length == 0
      title = find_title(link)
    end
    unless title
      raise "cannot find title for #{link}"
    end
    extra_fields ||= {}
    fields = extra_fields.merge({
      title: title,
      link: link,
      body: body,
    })
    post = Post.new(fields)

    begin
      existing_post = read_post(post.dir, post.slug, extra_fields)
    rescue InvalidDataError => e
      $stderr.puts "[HarpBlog#create_post] deleting post with invalid data: #{e.message}"
      delete_post_from_dir(post.dir, post.slug)
      existing_post = nil
    end

    if existing_post
      raise PostExistsError.new("post exists: #{post.dir}/#{post.slug}")
    else
      save_post('create post', post)
    end
  end

  def update_post(post, title, body, link)
    post.title = title
    post.body = body
    post.link = link
    save_post('update post', post)
  end

  def delete_post(year, month, slug)
    delete_post_from_dir(File.join(year, month), slug)
  end

  def delete_draft(slug)
    delete_post_from_dir('drafts', slug)
  end

  def publish_post(post)
    if post.draft?
      new_post = create_post(post.title, post.body, post.link)
      delete_post_from_dir('drafts', post.slug)
      new_post
    else
      raise PostAlreadyPublishedError.new("post is already published: #{post.dir}/#{post.slug}")
    end
  end

  def unpublish_post(post)
    if post.draft?
      raise PostNotPublishedError.new("post is not published: #{post.dir}/#{post.slug}")
    else
      new_post = create_post(post.title, post.body, post.link, draft: true)
      delete_post_from_dir(post.dir, post.slug)
      new_post
    end
  end

  def publish(production = false)
    target = production ? 'publish' : 'publish_beta'
    run("make #{target}")
  end


  private

  def find_title(url)
    @title_finder.find_title(url)
  end

  def path_for(*components)
    File.join(@path, *components)
  end

  def post_path(*components)
    path_for('public/posts', *components)
  end

  def drafts_path(*components)
    post_path('drafts', *components)
  end

  def read_posts(post_dir, extra_fields = nil)
    post_data = read_post_data(post_path(post_dir))
    post_data.sort_by do |k, v|
      (v['timestamp'] || Time.now).to_i
    end.map do |slug, fields|
      Post.new(fields.merge(extra_fields || {}).merge(slug: slug))
    end
  end

  def read_post(post_dir, slug, extra_fields = nil)
    post_filename = post_path(post_dir, "#{slug}.md")
    post_data = read_post_data(post_path(post_dir))
    if File.exist?(post_filename) && fields = post_data[slug]
      fields[:body] = File.read(post_filename)
      Post.new(fields.merge(extra_fields || {}).merge(slug: slug))
    elsif fields
      message = "missing post body for #{post_dir}/#{slug}: #{post_filename}"
      $stderr.puts "[HarpBlog#read_post] #{message}"
      raise InvalidDataError.new(message)
    elsif File.exist?(post_filename)
      message = "missing metadata for #{post_dir}/#{slug}: #{post_dir}/_data.json"
      $stderr.puts "[HarpBlog#read_post] #{message}"
      raise InvalidDataError.new(message)
    end
  end

  def save_post(action, post)
    git_fetch
    git_reset_hard('origin/master')

    begin
      write_post(post)
      git_commit(action, post.title, post_path(post.dir))
      git_push
      post

    rescue => e
      $stderr.puts "#{e.class}: #{e.message}"
      $stderr.puts e.backtrace
      git_reset_hard
      raise PostSaveError.new('failed to save post', e)
    end
  end

  def write_post(post)
    post_dir = post_path(post.dir)
    unless post.draft?
      ensure_post_dir_exists(post_dir)
    end
    write_post_body(post_dir, post.slug, post.body)
    begin
      write_post_index(post_dir, post.slug, post.persistent_fields)
    rescue => e
      $stderr.puts "#{e.class}: #{e.message}"
      $stderr.puts e.backtrace
      delete_post_body(post_dir, post.slug)
      raise e
    end
  end

  def delete_post_from_dir(post_dir, slug)
    post_dir = post_path(post_dir)
    delete_post_body(post_dir, slug)
    delete_post_index(post_dir, slug)
  end

  def write_post_body(dir, slug, body)
    post_filename = File.join(dir, "#{slug}.md")
    write_file(post_filename, body)
  end

  def delete_post_body(dir, slug)
    post_filename = File.join(dir, "#{slug}.md")
    delete_file(post_filename)
  end

  def write_post_index(dir, slug, fields)
    post_data = read_post_data(dir)
    post_data[slug] = fields
    write_post_data(dir, post_data)
  end

  def delete_post_index(dir, slug)
    post_data = read_post_data(dir)
    if post_data[slug]
      post_data.delete(slug)
      write_post_data(dir, post_data)
    end
  end

  def ensure_post_dir_exists(dir)
    monthly_index_filename = File.join(dir, 'index.ejs')
    unless File.exist?(monthly_index_filename)
      source = File.join(dir, '../../2006/02/index.ejs')
      cp(source, monthly_index_filename)
    end

    yearly_index_filename = File.join(dir, '../index.ejs')
    unless File.exist?(yearly_index_filename)
      source = File.join(dir, '../../2006/index.ejs')
      cp(source, yearly_index_filename)
    end
  end

  def read_post_data(dir)
    post_data_filename = File.join(dir, '_data.json')
    if File.exist?(post_data_filename)
      JSON.parse(File.read(post_data_filename))
    else
      {}
    end
  end

  def write_post_data(dir, data)
    post_data_filename = File.join(dir, '_data.json')
    json = JSON.pretty_generate(data)
    write_file(post_data_filename, json)
  end

  def ensure_dir_exists(dir)
    unless File.directory?(dir)
      if @dry_run
        puts ">>> mkdir -p '#{dir}'"
      else
        FileUtils.mkdir_p(dir)
      end
    end
  end

  def cp(source, destination, clobber = false)
    ensure_dir_exists(File.dirname(destination))
    if !File.exist?(destination) || clobber
      if @dry_run
        puts ">>> cp '#{source}' '#{destination}'"
      else
        FileUtils.cp(source, destination)
      end
    end
  end

  def write_file(filename, data)
    ensure_dir_exists(File.dirname(filename))
    if @dry_run
      puts ">>> write file '#{filename}', contents:"
      puts data
    else
      File.open(filename, 'w') do |f|
        f.puts(data)
      end
    end
  end

  def delete_file(filename)
    if File.exist?(filename)
      if @dry_run
        puts ">>> unlink '#{filename}'"
      else
        File.unlink(filename)
      end
    end
  end

  def quote(s)
    s.gsub('"', '\\"')
  end

  def run(cmd)
    if @dry_run
      puts ">>> cd '#{@path}' && #{cmd}"
    else
      `cd '#{@path}' && #{cmd} 2>&1`
    end
  end

  def git_sha
    if output = run('git log -n1 | head -n1 | cut -d" " -f2')
      output.strip
    else
      'fake-sha'
    end
  end

  def git_commit(action, title, *files)
    quoted_files = files.map { |f| "\"#{quote(f)}\"" }
    message = "#{action} '#{quote(title)}'"
    run("git add -A #{quoted_files.join(' ')} && git commit -m \"#{message}\"")
  end

  def git_fetch
    run('git fetch')
  end

  def git_reset_hard(ref = nil)
    args = ref ? "'#{ref}'" : ''
    run("git reset --hard #{args}")
  end

  def git_push(force = false)
    args = force ? '-f' : ''
    run("git push #{args}")
  end

end
