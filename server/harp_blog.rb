require 'fileutils'
require 'json'
require './web_title_finder'

class HarpBlog

  class HarpBlogError < RuntimeError ; end
  class InvalidDataError < HarpBlogError ; end
  class PostExistsError < HarpBlogError ; end

  class PostSaveError < HarpBlogError
    attr_reader :original_error
    def initialize(message, original_error)
      super(message)
      @original_error = original_error
    end
  end

  class Post
    PERSISTENT_FIELDS = %w[author title date timestamp link url tags].map(&:to_sym)
    TRANSIENT_FIELDS = %w[time slug body].map(&:to_sym)
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

    def title=(title)
      @slug = nil
      @title = title
    end

    def author
      @author ||= 'Sami Samhuri'
    end

    def time
      @time ||= @timestamp ? Time.at(@timestamp) : Time.now
    end

    def timestamp
      @timestamp ||= time.to_i
    end

    def url
      @url ||= "/posts/#{time.year}/#{padded_month}/#{slug}"
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

    def pad(n)
      n.to_i < 10 ? "0#{n}" : "#{n}"
    end
  end # Post


  def initialize(path, dry_run = true, title_finder = nil)
    @path = path
    @dry_run = dry_run
    @title_finder = title_finder || WebTitleFinder.new
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
    post_dir = post_path(year, month)
    post_data = read_post_data(post_dir)
    post_data.values.sort_by { |p| p['timestamp'] }.map { |p| Post.new(p) }
  end

  def get_post(year, month, slug)
    post_dir = post_path(year, month)
    post_filename = File.join(post_dir, "#{slug}.md")
    post_data = read_post_data(post_dir)
    if File.exist?(post_filename) && fields = post_data[slug]
      fields[:body] = File.read(post_filename)
      Post.new(fields)
    elsif fields
      message = "missing post body for #{year}/#{month}/#{slug}: #{post_filename}"
      $stderr.puts "[HarpBlog#get_post] #{message}"
      raise InvalidDataError.new(message)
    elsif File.exist?(post_filename)
      message = "missing metadata for #{year}/#{month}/#{slug}: #{post_dir}/_data.json"
      $stderr.puts "[HarpBlog#get_post] #{message}"
      raise InvalidDataError.new(message)
    end
  end

  def create_post(title, body, link)
    if !title || title.strip.length == 0
      title = find_title(link)
    end
    unless title
      raise "cannot find title for #{link}"
    end
    fields = {
      title: title,
      link: link,
      body: body,
    }
    post = Post.new(fields)
    year, month, slug = post.time.year, post.padded_month, post.slug

    begin
      existing_post = get_post(year.to_s, month, slug)
    rescue InvalidDataError => e
      $stderr.puts "[HarpBlog#create_post] deleting post with invalid data: #{e.message}"
      delete_post(year.to_s, month, slug)
      existing_post = nil
    end

    if existing_post
      raise PostExistsError.new("post exists: #{year}/#{month}/#{slug}")
    else
      save_post(post)
    end
  end

  def update_post(post, title, body, link)
    old_slug = post.slug
    post.title = title
    post.body = body
    post.link = link
    save_post(post, old_slug)
  end

  def delete_post(year, month, slug)
    post_dir = post_path(year, month)
    delete_post_body(post_dir, slug)
    delete_post_index(post_dir, slug)
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

  def save_post(post, old_slug = nil)
    git_fetch
    git_reset_hard('origin/master')

    begin
      post_dir = write_post(post, old_slug)
      git_commit(post.title, post_dir)
      git_push
      post

    rescue => e
      git_reset_hard
      raise PostSaveError.new('failed to save post', e)
    end
  end

  def write_post(post, old_slug = nil)
    post_dir = post_path(post.time.year.to_s, post.padded_month)
    ensure_post_dir_exists(post_dir)
    if old_slug
      delete_post_body(post_dir, old_slug)
      delete_post_index(post_dir, old_slug)
    end
    write_post_body(post_dir, post.slug, post.body)
    begin
      write_post_index(post_dir, post.slug, post.persistent_fields)
    rescue => e
      delete_post_body(post_dir, post.slug)
      raise e
    end
    post_dir
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
    post_data.delete(slug)
    write_post_data(dir, post_data)
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

  def git_commit(title, *files)
    quoted_files = files.map { |f| "\"#{quote(f)}\"" }
    message = "linked '#{quote(title)}'"
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
