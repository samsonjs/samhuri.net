require 'json'
require_relative './helpers'
require_relative '../harp_blog'

TEST_BLOG_PATH = File.expand_path('../../test-blog', __FILE__)
TEST_BLOG_ORIGIN_PATH = File.expand_path('../../test-blog-origin.git', __FILE__)

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe HarpBlog::Post do

  # Persistent fields: author, title, date, timestamp, link, url, tags
  # Transient fields: time, slug, body

  before :all do
    @default_fields = {
      title: 'samhuri.net',
      link: 'http://samhuri.net',
      body: 'this site is sick',
    }
    @default_slug = 'samhuri-net'
  end

  describe '#new' do
    it "takes a Hash of fields" do
      fields = @default_fields
      post = HarpBlog::Post.new(fields)
      expect(post.title).to eq(fields[:title])
      expect(post.link).to eq(fields[:link])
      expect(post.body).to eq(fields[:body])
    end

    it "accepts no parameters" do
      post = HarpBlog::Post.new
      expect(post).to be_truthy
    end

    it "ignores unknown fields" do
      post = HarpBlog::Post.new(what: 'is this')
      expect(post).to be_truthy
    end
  end

  describe '#persistent_fields' do
    it "contains all expected fields" do
      all_keys = HarpBlog::Post::PERSISTENT_FIELDS.sort
      post = HarpBlog::Post.new
      expect(all_keys).to eq(post.persistent_fields.keys.sort)
    end
  end

  describe '#fields' do
    it "contains all expected fields" do
      all_keys = HarpBlog::Post::FIELDS.sort
      post = HarpBlog::Post.new
      expect(all_keys).to eq(post.fields.keys.sort)
    end
  end

  describe '#link?' do
    it "returns true for link posts" do
      post = HarpBlog::Post.new(link: @default_fields[:link])
      expect(post.link?).to eq(true)
    end

    it "returns false for article posts" do
      post = HarpBlog::Post.new
      expect(post.link?).to eq(false)
    end
  end

  describe '#time' do
    it "should be derived from the timestamp if necessary" do
      timestamp = Time.now.to_i
      post = HarpBlog::Post.new(timestamp: timestamp)
      expect(post.time.to_i).to eq(timestamp)
    end
  end

  describe '#timestamp' do
    it "should be derived from the time if necessary" do
      time = Time.now - 42
      post = HarpBlog::Post.new(time: time)
      expect(post.timestamp).to eq(time.to_i)
    end
  end

  describe '#url' do
    it "should be derived from the time and slug if necessary" do
      post = HarpBlog::Post.new(@default_fields)
      year = post.time.year.to_s
      month = post.time.month
      padded_month = month < 10 ? " #{month}" : "#{month}"
      expect(post.url).to eq("/posts/#{year}/#{padded_month}/#{@default_slug}")
    end
  end

  describe '#slug' do
    it "should be derived from the title if necessary" do
      post = HarpBlog::Post.new(@default_fields)
      expect(post.slug).to eq(@default_slug)
    end

    it "should strip apostrophes" do
      post = HarpBlog::Post.new(title: "sjs's post")
      expect(post.slug).to eq('sjss-post')
    end

    it "should replace most non-word characters with dashes" do
      post = HarpBlog::Post.new(title: 'foo/bår!baz_quüx42')
      expect(post.slug).to eq('foo-bår-baz_quüx42')
    end

    it "should strip leading and trailing dashes" do
      post = HarpBlog::Post.new(title: '!foo?bar!')
      expect(post.slug).to eq('foo-bar')
    end

    it "should collapse runs of dashes" do
      post = HarpBlog::Post.new(title: 'foo???bar')
      expect(post.slug).to eq('foo-bar')
    end
  end

  describe '#pad' do
    it "should have a leading zero for integers 0 < n < 10" do
      post = HarpBlog::Post.new
      expect(post.pad(1)).to eq('01')
      expect(post.pad(9)).to eq('09')
    end

    it "should not have a leading zero for integers n >= 10" do
      post = HarpBlog::Post.new
      expect(post.pad(10)).to eq('10')
      expect(post.pad(12)).to eq('12')
    end
  end
end

RSpec.describe HarpBlog do
  before :each do
    @test_blog_ref = git_sha(TEST_BLOG_PATH)
    dry_run = false
    @blog = HarpBlog.new(TEST_BLOG_PATH, dry_run)
  end

  after :each do
    git_reset_hard(TEST_BLOG_PATH, @test_blog_ref)
    force = true
    @blog.send(:git_push, force)
  end

  describe '#new' do
    it "should optionally accept dry_run" do
      expect(@blog).to be_truthy

      blog = HarpBlog.new(TEST_BLOG_PATH)
      expect(blog).to be_truthy
    end
  end

  describe '#years' do
    it "should return all of the years with posts" do
      # yup, if I don't blog for an entire year that's a bug!
      years = (2006..Date.today.year).to_a.map(&:to_s)
      expect(@blog.years).to eq(years)
    end
  end

  describe '#months' do
    it "should return all of the years and months with posts" do
      months = [
        ["2006", "02"], ["2006", "03"], ["2006", "04"], ["2006", "05"], ["2006", "06"], ["2006", "07"], ["2006", "08"], ["2006", "09"], ["2006", "12"],
        ["2007", "03"], ["2007", "04"], ["2007", "05"], ["2007", "06"], ["2007", "07"], ["2007", "08"], ["2007", "09"], ["2007", "10"],
        ["2008", "01"], ["2008", "02"], ["2008", "03"],
        ["2009", "11"],
        ["2010", "01"], ["2010", "11"],
        ["2011", "11"], ["2011", "12"],
        ["2012", "01"],
        ["2013", "03"], ["2013", "09"],
      ]
      expect(@blog.months.first(months.length)).to eq(months)
    end
  end

  describe '#posts_for_month' do
    it "should return the correct number of posts" do
      expect(@blog.posts_for_month('2006', '02').length).to eq(12)
    end

    it "should sort the posts by publish time" do
      timestamps = @blog.posts_for_month('2006', '02').map(&:timestamp)
      expect(increasing?(timestamps)).to be_truthy
    end
  end

  describe '#posts_for_year' do
    it "should return the correct number of posts" do
      expect(@blog.posts_for_year('2006').length).to eq(31)
    end

    it "should sort the posts by publish time" do
      timestamps = @blog.posts_for_year('2006').map(&:timestamp)
      expect(increasing?(timestamps)).to be_truthy
    end
  end

  describe '#create_post' do
    it "should create a link post when a link is given" do
      title = 'test post'
      body = 'check this out'
      link = 'http://samhuri.net'
      post = @blog.create_post(title, body, link)
      expect(post).to be_truthy
      expect(post.link?).to be_truthy
      expect(post.title).to eq(title)
      expect(post.body).to eq(body)
      expect(post.link).to eq(link)
      expect(post.time.to_date).to eq(Date.today)
    end

    it "should create an article post when no link is given" do
      title = 'test post'
      body = 'check this out'
      post = @blog.create_post(title, body, nil)
      expect(post).to be_truthy
      expect(post.link?).to be_falsy
      expect(post.title).to eq(title)
      expect(post.body).to eq(body)
      expect(post.link).to eq(nil)
      expect(post.time.to_date).to eq(Date.today)
    end

    it "should create a post that can be fetched immediately" do
      title = 'fetch now'
      body = 'blah blah blah'
      post = @blog.create_post(title, body, nil)
      expect(post).to be_truthy

      today = Date.today
      year = today.year.to_s
      month = post.pad(today.month)
      fetched_post = @blog.get_post(year, month, post.slug)
      expect(post.url).to eq(fetched_post.url)
    end

    it "should fetch titles if necessary" do
      class TitleFinder
        def find_title(url) 'fancy title' end
      end
      dry_run = false
      blog = HarpBlog.new(TEST_BLOG_PATH, dry_run, TitleFinder.new)
      post = blog.create_post(nil, nil, 'http://samhuri.net')
      expect(post.title).to eq('fancy title')
      blog.delete_post(post.time.year.to_s, post.padded_month, post.slug)
      post = blog.create_post(" \t\n", nil, 'http://samhuri.net')
      expect(post.title).to eq('fancy title')
    end

    it "should push the new post to the origin repo" do
      title = 'fetch now'
      body = 'blah blah blah'
      post = @blog.create_post(title, body, nil)
      local_sha = git_sha(TEST_BLOG_PATH)
      origin_sha = git_sha(TEST_BLOG_ORIGIN_PATH)
      expect(origin_sha).to eq(local_sha)
    end
  end

  describe '#get_post' do
    it "should return complete posts" do
      first_post_path = File.join(TEST_BLOG_PATH, 'public/posts/2006/02/first-post.md')
      post = @blog.get_post('2006', '02', 'first-post')
      expect(post).to be_truthy
      expect(post.author).to eq('Sami Samhuri')
      expect(post.title).to eq('First Post!')
      expect(post.slug).to eq('first-post')
      expect(post.timestamp).to eq(1139368860)
      expect(post.date).to eq('8th February, 2006')
      expect(post.url).to eq('/posts/2006/02/first-post')
      expect(post.link).to eq(nil)
      expect(post.link?).to eq(false)
      expect(post.tags).to eq(['life'])
      expect(post.body).to eq(File.read(first_post_path))
    end

    it "should return nil if the post does not exist" do
      post = @blog.get_post('2005', '01', 'anything')
      expect(post).to be(nil)
    end
  end

  describe '#update_post' do
    it "should immediately reflect changes when fetched" do
      post = @blog.get_post('2006', '02', 'first-post')
      title = 'new title'
      body = "new body\n"
      link = 'new link'
      @blog.update_post(post, title, body, link)

      # new slug, new data
      post = @blog.get_post('2006', '02', 'new-title')
      expect(post.title).to eq(title)
      expect(post.body).to eq(body)
      expect(post.link).to eq(link)

      # old post is long gone
      post = @blog.get_post('2006', '02', 'first-post')
      expect(post).to eq(nil)
    end
  end

  describe '#delete_post' do
    it "should delete existing posts" do
      post = @blog.get_post('2006', '02', 'first-post')
      expect(post).to be_truthy

      @blog.delete_post('2006', '02', 'first-post')

      post = @blog.get_post('2006', '02', 'first-post')
      expect(post).to eq(nil)
    end

    it "should do nothing for non-existent posts" do
      post = @blog.get_post('2006', '02', 'first-post')
      expect(post).to be_truthy

      @blog.delete_post('2006', '02', 'first-post')
      @blog.delete_post('2006', '02', 'first-post')
    end
  end

end
