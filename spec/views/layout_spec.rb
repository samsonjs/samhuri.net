require "spec_helper"

RSpec.describe Pressa::Views::Layout do
  let(:test_content_view) do
    Class.new(Phlex::HTML) do
      def view_template
        article do
          h1 { "Hello" }
        end
      end
    end.new
  end

  let(:site) do
    Pressa::Site.new(
      author: "Sami Samhuri",
      email: "sami@samhuri.net",
      title: "samhuri.net",
      description: "blog",
      url: "https://samhuri.net"
    )
  end

  it "renders child components as HTML instead of escaped text" do
    html = described_class.new(
      site:,
      canonical_url: "https://samhuri.net/posts/",
      content: test_content_view
    ).call

    expect(html).to include("<article>")
    expect(html).to include("<h1>Hello</h1>")
    expect(html).not_to include("&lt;article&gt;")
  end

  it "keeps escaping enabled for untrusted string fields" do
    subtitle = "<img src=x onerror=alert(1)>"
    html = described_class.new(
      site:,
      canonical_url: "https://samhuri.net/posts/",
      page_subtitle: subtitle,
      content: test_content_view
    ).call

    expect(html).to include("<title>samhuri.net: &lt;img src=x onerror=alert(1)&gt;</title>")
  end
end
