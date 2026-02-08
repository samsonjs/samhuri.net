require 'spec_helper'
require 'json'
require 'tmpdir'

RSpec.describe Pressa::Posts::JSONFeedWriter do
  let(:site) do
    Pressa::Site.new(
      author: 'Sami Samhuri',
      email: 'sami@samhuri.net',
      title: 'samhuri.net',
      description: 'blog',
      url: 'https://samhuri.net',
      image_url: 'https://samhuri.net/images/me.jpg'
    )
  end

  let(:posts_by_year) { double('posts_by_year', recent_posts: [post]) }
  let(:writer) { described_class.new(site:, posts_by_year:) }

  context 'for link posts' do
    let(:post) do
      Pressa::Posts::Post.new(
        slug: 'github-flow-like-a-pro',
        title: 'GitHub Flow Like a Pro',
        author: 'Sami Samhuri',
        date: DateTime.parse('2015-05-28T07:42:27-07:00'),
        formatted_date: '28th May, 2015',
        link: 'http://haacked.com/archive/2014/07/28/github-flow-aliases/',
        body: '<p>hello</p>',
        excerpt: 'hello...',
        path: '/posts/2015/05/github-flow-like-a-pro'
      )
    end

    it 'uses permalink as url and keeps external_url for destination links' do
      Dir.mktmpdir do |dir|
        writer.write_feed(target_path: dir, limit: 30)
        feed = JSON.parse(File.read(File.join(dir, 'feed.json')))
        item = feed.fetch('items').first

        expect(item.fetch('id')).to eq('https://samhuri.net/posts/2015/05/github-flow-like-a-pro')
        expect(item.fetch('url')).to eq('https://samhuri.net/posts/2015/05/github-flow-like-a-pro')
        expect(item.fetch('external_url')).to eq('http://haacked.com/archive/2014/07/28/github-flow-aliases/')
      end
    end
  end

  context 'for regular posts' do
    let(:post) do
      Pressa::Posts::Post.new(
        slug: 'swift-optional-or',
        title: 'Swift Optional OR',
        author: 'Sami Samhuri',
        date: DateTime.parse('2017-10-01T10:00:00-07:00'),
        formatted_date: '1st October, 2017',
        body: '<p>hello</p>',
        excerpt: 'hello...',
        path: '/posts/2017/10/swift-optional-or'
      )
    end

    it 'omits external_url' do
      Dir.mktmpdir do |dir|
        writer.write_feed(target_path: dir, limit: 30)
        feed = JSON.parse(File.read(File.join(dir, 'feed.json')))
        item = feed.fetch('items').first

        expect(item.fetch('url')).to eq('https://samhuri.net/posts/2017/10/swift-optional-or')
        expect(item).not_to have_key('external_url')
      end
    end
  end
end
