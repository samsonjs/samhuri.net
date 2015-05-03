require_relative '../harp_blog/post'

RSpec.describe HarpBlog::Post do

  # Persistent fields: id, author, title, date, timestamp, link, url, tags
  # Transient fields: time, slug, body

  before :all do
    @post_fields = {
        title: 'samhuri.net',
        link: 'https://samhuri.net',
        body: 'this site is sick',
    }
    @post_slug = 'samhuri-net'
    @draft_fields = {
        title: 'reddit.com',
        link: 'http://reddit.com',
        body: 'hi reddit',
        draft: true,
        id: 'dummy-draft-id',
    }
  end

  describe '#new' do
    it "takes a Hash of fields" do
      fields = @post_fields
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
      post = HarpBlog::Post.new(link: @post_fields[:link])
      expect(post.link?).to be_truthy
    end

    it "returns false for article posts" do
      post = HarpBlog::Post.new
      expect(post.link?).to be_falsy
    end
  end

  describe '#draft?' do
    it "returns true for draft posts" do
      post = HarpBlog::Post.new(draft: true)
      expect(post.draft?).to be_truthy
    end

    it "returns false for published posts" do
      post = HarpBlog::Post.new
      expect(post.draft?).to be_falsy
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
      post = HarpBlog::Post.new(@post_fields)
      year = post.time.year.to_s
      month = post.time.month
      padded_month = month < 10 ? "0#{month}" : "#{month}"
      expect(post.url).to eq("/posts/#{year}/#{padded_month}/#{@post_slug}")
    end
  end

  describe '#id' do
    it "should be generated for drafts if necessary" do
      draft = HarpBlog::Post.new(@draft_fields)
      expect(draft.id).to eq(@draft_fields[:id])

      draft = HarpBlog::Post.new(@draft_fields.merge(id: nil))
      expect(draft.id).to_not eq(@draft_fields[:id])
    end

    it "should be the slug for posts" do
      post = HarpBlog::Post.new(@post_fields)
      expect(post.id).to eq(post.slug)
    end
  end

  describe '#slug' do
    it "should be derived from the title if necessary" do
      post = HarpBlog::Post.new(@post_fields)
      expect(post.slug).to eq(@post_slug)
    end

    it "should be nil for drafts" do
      draft = HarpBlog::Post.new(@draft_fields)
      expect(draft.slug).to be_nil
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

  describe '#dir' do
    it "returns the drafts dir for draft posts" do
      post = HarpBlog::Post.new(draft: true)
      expect(post.dir).to eq('drafts')
    end

    it "returns the dated dir for published posts" do
      post = HarpBlog::Post.new
      expect(post.dir).to eq("#{post.time.year}/#{post.padded_month}")
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
