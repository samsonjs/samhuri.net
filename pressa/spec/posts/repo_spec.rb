require 'spec_helper'
require 'fileutils'
require 'tmpdir'

RSpec.describe Pressa::Posts::PostRepo do
  let(:repo) { described_class.new }

  describe '#read_posts' do
    it 'reads and organizes posts by year and month' do
      Dir.mktmpdir do |tmpdir|
        posts_dir = File.join(tmpdir, 'posts', '2025', '11')
        FileUtils.mkdir_p(posts_dir)

        post_content = <<~MARKDOWN
          ---
          Title: Shredding in November
          Author: Shaun White
          Date: 5th November, 2025
          Timestamp: 2025-11-05T10:00:00-08:00
          ---

          Had an epic day at Whistler. The powder was deep and the lines were short.
        MARKDOWN

        File.write(File.join(posts_dir, 'shredding.md'), post_content)

        posts_by_year = repo.read_posts(File.join(tmpdir, 'posts'))

        expect(posts_by_year.all_posts.length).to eq(1)

        post = posts_by_year.all_posts.first
        expect(post.title).to eq('Shredding in November')
        expect(post.author).to eq('Shaun White')
        expect(post.slug).to eq('shredding')
        expect(post.year).to eq(2025)
        expect(post.month).to eq(11)
        expect(post.path).to eq('/posts/2025/11/shredding')
      end
    end

    it 'generates excerpts from post content' do
      Dir.mktmpdir do |tmpdir|
        posts_dir = File.join(tmpdir, 'posts', '2025', '11')
        FileUtils.mkdir_p(posts_dir)

        post_content = <<~MARKDOWN
          ---
          Title: Test Post
          Author: Greg Graffin
          Date: 5th November, 2025
          Timestamp: 2025-11-05T10:00:00-08:00
          ---

          This is a test post with some content. It should generate an excerpt.

          ![Image](image.png)

          More content with a [link](https://example.net).
        MARKDOWN

        File.write(File.join(posts_dir, 'test.md'), post_content)

        posts_by_year = repo.read_posts(File.join(tmpdir, 'posts'))
        post = posts_by_year.all_posts.first

        expect(post.excerpt).to include('test post')
        expect(post.excerpt).not_to include('![')
        expect(post.excerpt).to include('link')
        expect(post.excerpt).not_to include('[link]')
      end
    end
  end
end
