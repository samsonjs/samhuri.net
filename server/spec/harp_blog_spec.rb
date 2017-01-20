require 'json'
require_relative './helpers'
require_relative '../harp_blog'

TEST_BLOG_PATH = File.expand_path('../../test-blog', __FILE__)
TEST_BLOG_ORIGIN_PATH = File.expand_path('../../test-blog-origin.git', __FILE__)

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe HarpBlog do
  before :each do
    @test_blog_ref = git_sha(TEST_BLOG_PATH)
    dry_run = false
    @mock_title = 'fancy title'
    @mock_title_finder = mock_title_finder(@mock_title)
    @mock_version_finder = mock_version_finder(@test_blog_ref)
    @blog = HarpBlog.new(TEST_BLOG_PATH, dry_run, @mock_title_finder, @mock_version_finder)
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

  describe '#local_version' do
    it "should expose the local version" do
      expect(@blog.local_version).to eq(@test_blog_ref)
    end
  end

  describe '#remote_version' do
    it "should expose the remote version" do
      expect(@blog.remote_version).to eq(@test_blog_ref)
    end
  end

  describe '#dirty?' do
    it "should specify whether or not there are unpublished changes" do
      expect(@blog.dirty?).to be_falsy

      @blog.create_post('title', 'body', nil)
      expect(@blog.dirty?).to be_truthy

      @mock_version_finder.version = @blog.local_version
      expect(@blog.dirty?).to be_falsy
    end
  end

  describe '#status' do
    it "should expose the local and remote versions, and dirty state" do
      status = @blog.status
      expect(status['local-version']).to eq(@blog.local_version)
      expect(status['remote-version']).to eq(@blog.remote_version)
      expect(status['dirty']).to eq(@blog.dirty?)
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

  describe '#drafts' do
    it "returns the correct number of posts" do
      expect(@blog.drafts.length).to eq(2)
    end

    it "should sort the posts by publish time" do
      timestamps = @blog.drafts.map(&:timestamp)
      expect(increasing?(timestamps)).to be_truthy
    end
  end

  describe '#get_post' do
    it "should return complete posts" do
      first_post_path = File.join(TEST_BLOG_PATH, 'public/posts/2006/02/first-post.md')
      post = @blog.get_post('2006', '02', 'first-post')
      expect(post).to be_truthy
      expect(post.author).to eq('Sami J. Samhuri')
      expect(post.title).to eq('First Post!')
      expect(post.slug).to eq('first-post')
      expect(post.timestamp).to eq(1139368860)
      expect(post.date).to eq('8th February, 2006')
      expect(post.url).to eq('/posts/2006/02/first-post')
      expect(post.link).to eq(nil)
      expect(post.link?).to be_falsy
      expect(post.tags).to eq(['life'])
      expect(post.body).to eq(File.read(first_post_path))
    end

    it "should return nil if the post does not exist" do
      post = @blog.get_post('2005', '01', 'anything')
      expect(post).to be(nil)
    end
  end

  describe '#get_draft' do
    it "should return complete posts" do
      id = 'some-draft-id'
      title = 'new draft'
      body = "blah blah blah\n"
      @blog.create_post(title, body, nil, id: id, draft: true)
      draft = @blog.get_draft(id)
      expect(draft).to be_truthy
      expect(draft.title).to eq(title)
      expect(draft.url).to eq("/posts/drafts/#{id}")
      expect(draft.draft?).to be_truthy
      expect(draft.body).to eq(body)
    end

    it "should return nil if the post does not exist" do
      draft = @blog.get_draft('does-not-exist')
      expect(draft).to be(nil)
    end
  end

  describe '#create_post' do
    it "should create a link post when a link is given" do
      title = 'test post'
      body = 'check this out'
      link = 'https://samhuri.net'
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

    it "should create a draft post" do
      title = 'test draft'
      body = 'check this out'
      post = @blog.create_post(title, body, nil, draft: true)
      expect(post).to be_truthy
      expect(post.draft?).to be_truthy
      expect(post.dir).to eq('drafts')
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
      expect(fetched_post.url).to eq(post.url)
    end

    it "should create a draft that can be fetched immediately" do
      id = 'another-draft-id'
      title = 'fetch now'
      body = 'blah blah blah'
      draft = @blog.create_post(title, body, nil, id: id, draft: true)
      expect(draft).to be_truthy

      fetched_draft = @blog.get_draft(draft.id)
      expect(draft.url).to eq(fetched_draft.url)
    end

    it "should fetch titles if necessary" do
      post = @blog.create_post(nil, nil, 'https://samhuri.net')
      expect(post.title).to eq(@mock_title)
      @blog.delete_post(post.time.year.to_s, post.padded_month, post.slug)
      post = @blog.create_post(" \t\n", nil, 'https://samhuri.net')
      expect(post.title).to eq(@mock_title)
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
      post = @blog.get_post('2006', '02', 'first-post')
      expect(post.title).to eq(title)
      expect(post.body).to eq(body)
      expect(post.link).to eq(link)
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

  describe '#delete_draft' do
    it "should delete existing drafts" do
      id = 'bunk-draft-id'
      title = 'new draft'
      body = 'blah blah blah'
      existing_draft = @blog.create_post(title, body, nil, id: id, draft: true)
      draft = @blog.get_draft(existing_draft.id)
      expect(draft).to be_truthy

      @blog.delete_draft(draft.id)

      draft = @blog.get_draft(draft.id)
      expect(draft).to eq(nil)
    end

    it "should do nothing for non-existent posts" do
      id = 'missing-draft-id'
      title = 'new draft'
      body = 'blah blah blah'
      existing_draft = @blog.create_post(title, body, nil, id: id, draft: true)

      draft = @blog.get_draft(existing_draft.id)
      expect(draft).to be_truthy

      @blog.delete_draft(draft.id)
      expect(@blog.get_draft(existing_draft.id)).to be_nil
      @blog.delete_draft(draft.id)
    end
  end

  describe '#publish_post' do
    it "should publish drafts" do
      id = 'this-draft-is-a-keeper'
      title = 'a-shiny-new-post'
      body = 'blah blah blah'
      link = 'https://samhuri.net'
      draft = @blog.create_post(title, body, link, id: id, draft: true)
      post = @blog.publish_post(draft)
      expect(post).to be_truthy
      expect(post.id).to eq(post.slug)
      expect(post.draft?).to be_falsy
      expect(post.title).to eq(title)
      expect(post.body).to eq(body)
      expect(post.link).to eq(link)

      missing_draft = @blog.get_draft(draft.id)
      expect(missing_draft).to eq(nil)

      fetched_post = @blog.get_post(post.time.year.to_s, post.padded_month, post.slug)
      expect(fetched_post).to be_truthy
    end

    it "should raise an error for published posts" do
      post = @blog.get_post('2006', '02', 'first-post')
      expect { @blog.publish_post(post) }.to raise_error
    end
  end

  describe '#unpublish_post' do
    it "should unpublish posts" do
      post = @blog.get_post('2006', '02', 'first-post')
      draft = @blog.unpublish_post(post)
      expect(draft).to be_truthy
      expect(draft.id).to be_truthy
      expect(draft.draft?).to be_truthy
      expect(draft.title).to eq(post.title)
      expect(draft.body).to eq(post.body)
      expect(draft.link).to eq(post.link)

      missing_post = @blog.get_post(post.time.year.to_s, post.padded_month, post.slug)
      expect(missing_post).to eq(nil)

      fetched_draft = @blog.get_draft(draft.id)
      expect(fetched_draft).to be_truthy
    end

    it "should raise an error for drafts" do
      title = 'a-shiny-new-post'
      body = 'blah blah blah'
      link = 'https://samhuri.net'
      post = @blog.create_post(title, body, link, draft: true)
      expect { @blog.unpublish_post(post) }.to raise_error
    end
  end

end
