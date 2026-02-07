require 'spec_helper'

RSpec.describe Pressa::Posts::PostMetadata do
  describe '.parse' do
    it 'parses valid YAML front-matter' do
      content = <<~MARKDOWN
        ---
        Title: Test Post
        Author: Trent Reznor
        Date: 5th November, 2025
        Timestamp: 2025-11-05T10:00:00-08:00
        Tags: Ruby, Testing
        Scripts: highlight.js
        Styles: code.css
        Link: https://example.net/external
        ---

        This is the post body.
      MARKDOWN

      metadata = described_class.parse(content)

      expect(metadata.title).to eq('Test Post')
      expect(metadata.author).to eq('Trent Reznor')
      expect(metadata.formatted_date).to eq('5th November, 2025')
      expect(metadata.date.year).to eq(2025)
      expect(metadata.date.month).to eq(11)
      expect(metadata.date.day).to eq(5)
      expect(metadata.link).to eq('https://example.net/external')
      expect(metadata.tags).to eq(['Ruby', 'Testing'])
      expect(metadata.scripts.map(&:src)).to eq(['js/highlight.js'])
      expect(metadata.styles.map(&:href)).to eq(['css/code.css'])
    end

    it 'raises error when required fields are missing' do
      content = <<~MARKDOWN
        ---
        Title: Incomplete Post
        ---

        Body content
      MARKDOWN

      expect {
        described_class.parse(content)
      }.to raise_error(/Missing required fields/)
    end

    it 'handles posts without optional fields' do
      content = <<~MARKDOWN
        ---
        Title: Simple Post
        Author: Fat Mike
        Date: 1st January, 2025
        Timestamp: 2025-01-01T12:00:00-08:00
        ---

        Simple content
      MARKDOWN

      metadata = described_class.parse(content)

      expect(metadata.tags).to eq([])
      expect(metadata.scripts).to eq([])
      expect(metadata.styles).to eq([])
      expect(metadata.link).to be_nil
    end
  end
end
