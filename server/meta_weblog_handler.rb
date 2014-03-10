require 'fileutils'
require 'json'
require 'open-uri'
require 'xmlrpc/server'

class MetaWeblogHandler

  def newPost(site_id, username, password, post_hash, should_publish)
    if authenticated?(username, password)
      post_hash.each_key do |key|
        v = post_hash[key]
        if v.to_s.strip == ''
          post_hash.delete(key)
        end
      end

      url = post_hash['link']
      title = post_hash['title'] || find_title(url)
      body = post_hash['description'] || 'No description necessary.'

      unless title
        raise XMLRPC::FaultException.new(0, "no title given and cannot parse title")
      end

      create_link_post(url, title, body)

      1 # dummy post ID

    else
      raise XMLRPC::FaultException.new(0, "username or password invalid")
    end
  end


  private

  def find_title(url)
    body = open(url).read
    lines = body.split(/[\r\n]+/)
    title_line = lines.grep(/<title/).first.strip
    title_line.gsub(/\s*<\/?title[^>]*>\s*/, '')
  rescue
    nil
  end

  def create_link_post(url, title, body)
    slug = create_slug(title)
    time = Time.now
    date = time.strftime('%B %d, %Y')
    post_dir = File.join(samhuri_net_path, 'public/posts', time.year.to_s, pad(time.month))
    relative_url = "/posts/#{time.year}/#{pad(time.month)}/#{slug}"

    git_pull

    FileUtils.mkdir_p(post_dir)

    post_filename = File.join(post_dir, "#{slug}.md")
    File.open(post_filename, 'w') do |f|
      f.puts(body)
    end

    post_data = read_post_data(post_dir)
    post_data[slug] = {
      title: title,
      date: date,
      timestamp: time.to_i,
      tags: [],
      url: relative_url,
      link: url
    }
    write_post_data(post_dir, post_data)

    git_commit(title, post_dir)
    git_push
    publish

  rescue Exception => e
    git_reset
    raise e
  end

  def samhuri_net_path
    '/Users/sjs/Projects/samhuri.net-publish'
  end

  def create_slug(title)
    # TODO: be intelligent about unicode ... \p{Word} might help. negated char class with it?
    title.downcase.gsub(/[^\w]/, '-')
  end

  def pad(n)
    n.to_i < 10 ? "0#{n}" : "#{n}"
  end

  def read_post_data(dir)
    post_data_filename = File.join(dir, '_data.json')
    if File.exists?(post_data_filename)
      JSON.parse(File.read(post_data_filename))
    else
      {}
    end
  end

  def write_post_data(dir, data)
    post_data_filename = File.join(dir, '_data.json')
    json = JSON.pretty_generate(data)
    File.open(post_data_filename, 'w') do |f|
      f.puts(json)
    end
  end

  def quote(s)
    s.gsub('"', '\\"')
  end

  def git_commit(title, *files)
    quoted_files = files.map { |f| "\"#{quote(f)}\"" }
    message = "linked '#{quote(title)}'"
    `cd '#{samhuri_net_path}' && git add #{quoted_files.join(' ')} && git commit -m "#{message}"`
  end

  def git_pull
    `cd '#{samhuri_net_path}' && git pull -f`
  end

  def git_push
    `cd '#{samhuri_net_path}' && git push`
  end

  def git_reset
    `cd '#{samhuri_net_path}' && git reset --hard`
  end

  def publish
    `cd '#{samhuri_net_path}' && make publish`
  end

  def auth_json_filename
    File.expand_path('../auth.json', __FILE__)
  end

  def auth
    @auth ||= JSON.parse(File.read(auth_json_filename))
  end

  def authenticated?(username, password)
    auth['username'] == username && auth['password'] == password
  end

end
