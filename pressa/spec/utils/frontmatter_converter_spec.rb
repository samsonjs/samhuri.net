require 'spec_helper'
require_relative '../../lib/utils/frontmatter_converter'

RSpec.describe Pressa::Utils::FrontmatterConverter do
  describe '.convert_content' do
    it 'converts simple front-matter to YAML' do
      input = <<~MARKDOWN
        ---
        Title: Test Post
        Author: Sami Samhuri
        Date: 11th November, 2025
        Timestamp: 2025-11-11T14:00:00-08:00
        ---

        This is the post body.
      MARKDOWN

      output = described_class.convert_content(input)

      expect(output).to start_with("---\n")
      expect(output).to include("Title: Test Post")
      expect(output).to include("Author: Sami Samhuri")
      expect(output).to include("Date: \"11th November, 2025\"")
      expect(output).to include("Timestamp: \"2025-11-11T14:00:00-08:00\"")
      expect(output).to end_with("---\n\nThis is the post body.\n")
    end

    it 'converts front-matter with tags' do
      input = <<~MARKDOWN
        ---
        Title: Zelda Tones for iOS
        Author: Sami Samhuri
        Date: 6th March, 2013
        Timestamp: 2013-03-06T18:51:13-08:00
        Tags: zelda, nintendo, pacman, ringtones, tones, ios
        ---

        <h2>Zelda</h2>

        <p>
          <a href="http://mattgemmell.com">Matt Gemmell</a> recently shared some
          <a href="http://mattgemmell.com/2013/03/05/iphone-5-super-nintendo-wallpapers/">sweet Super Nintendo wallpapers for iPhone 5</a>.
        </p>
      MARKDOWN

      output = described_class.convert_content(input)

      expect(output).to include("Title: Zelda Tones for iOS")
      expect(output).to include("Tags: \"zelda, nintendo, pacman, ringtones, tones, ios\"")
      expect(output).to include("<h2>Zelda</h2>")
    end

    it 'converts front-matter with Link field' do
      input = <<~MARKDOWN
        ---
        Title: Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo
        Author: Sami Samhuri
        Date: 16th September, 2006
        Timestamp: 2006-09-16T22:11:00-07:00
        Tags: amusement, buffalo
        Link: http://en.wikipedia.org/wiki/Buffalo_buffalo_buffalo_buffalo_buffalo_buffalo_buffalo_buffalo
        ---

        Wouldn't the sentence 'I want to put a hyphen between the words Fish and And...
      MARKDOWN

      output = described_class.convert_content(input)

      expect(output).to include("Link: http://en.wikipedia.org/wiki/Buffalo_buffalo_buffalo_buffalo_buffalo_buffalo_buffalo_buffalo")
      expect(output).to include("Tags: \"amusement, buffalo\"")
    end

    it 'converts front-matter with Scripts and Styles' do
      input = <<~MARKDOWN
        ---
        Title: Code Example Post
        Author: Sami Samhuri
        Date: 1st January, 2025
        Timestamp: 2025-01-01T12:00:00-08:00
        Scripts: highlight.js, custom.js
        Styles: code.css, theme.css
        ---

        Some code here.
      MARKDOWN

      output = described_class.convert_content(input)

      expect(output).to include("Scripts: \"highlight.js, custom.js\"")
      expect(output).to include("Styles: \"code.css, theme.css\"")
    end

    it 'handles Date fields with colons correctly' do
      input = <<~MARKDOWN
        ---
        Title: Test
        Author: Sami Samhuri
        Date: 1st January, 2025
        Timestamp: 2025-01-01T12:00:00-08:00
        ---

        Body
      MARKDOWN

      output = described_class.convert_content(input)

      expect(output).to include("Date: \"1st January, 2025\"")
      expect(output).to include("Timestamp: \"2025-01-01T12:00:00-08:00\"")
    end

    it 'raises error if no front-matter delimiter' do
      input = "Just some content without front-matter"

      expect {
        described_class.convert_content(input)
      }.to raise_error("File does not start with front-matter delimiter")
    end

    it 'raises error if front-matter is not closed' do
      input = <<~MARKDOWN
        ---
        Title: Unclosed
        Author: Test

        Body without closing delimiter
      MARKDOWN

      expect {
        described_class.convert_content(input)
      }.to raise_error("Could not find end of front-matter")
    end

    it 'preserves empty lines in body' do
      input = <<~MARKDOWN
        ---
        Title: Test
        Author: Sami Samhuri
        Date: 1st January, 2025
        Timestamp: 2025-01-01T12:00:00-08:00
        ---

        First paragraph.

        Second paragraph after empty line.
      MARKDOWN

      output = described_class.convert_content(input)

      expect(output).to include("\nFirst paragraph.\n\nSecond paragraph after empty line.\n")
    end
  end

  describe '.convert_frontmatter_to_yaml' do
    it 'converts all standard fields' do
      input = <<~FRONTMATTER
        Title: Test Post
        Author: Sami Samhuri
        Date: 11th November, 2025
        Timestamp: 2025-11-11T14:00:00-08:00
        Tags: Ruby, Testing
        Link: https://example.net
        Scripts: app.js
        Styles: style.css
      FRONTMATTER

      yaml = described_class.convert_frontmatter_to_yaml(input)

      expect(yaml).to include("Title: Test Post")
      expect(yaml).to include("Author: Sami Samhuri")
      expect(yaml).to include("Date: \"11th November, 2025\"")
      expect(yaml).to include("Timestamp: \"2025-11-11T14:00:00-08:00\"")
      expect(yaml).to include("Tags: \"Ruby, Testing\"")
      expect(yaml).to include("Link: https://example.net")
      expect(yaml).to include("Scripts: app.js")
      expect(yaml).to include("Styles: style.css")
    end

    it 'handles empty lines gracefully' do
      input = <<~FRONTMATTER
        Title: Test

        Author: Sami Samhuri
        Date: 1st January, 2025

        Timestamp: 2025-01-01T12:00:00-08:00
      FRONTMATTER

      yaml = described_class.convert_frontmatter_to_yaml(input)

      expect(yaml).to include("Title: Test")
      expect(yaml).to include("Author: Sami Samhuri")
    end
  end
end
