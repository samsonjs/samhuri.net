require "rouge"

module Pressa
  module Utils
    # A drop-in replacement for Rouge::Formatters::HTMLLegacy, which kramdown uses
    # by default and which is deprecated upstream. Reproduces just the wrapping
    # behavior we rely on (a `.highlight`-wrapped `<pre><code>`), without the
    # deprecation warning.
    class RougeHTMLFormatter < Rouge::Formatter
      tag "pressa_html"

      def initialize(opts = {})
        @formatter = Rouge::Formatters::HTML.new
        @formatter = Rouge::Formatters::HTMLTable.new(@formatter, opts) if opts[:line_numbers]
        @wrap_css_class = opts.fetch(:css_class, "codehilite") if opts.fetch(:wrap, true)
      end

      def stream(tokens, &block)
        yield %(<div class="highlight"><pre class="#{@wrap_css_class}"><code>) if @wrap_css_class

        @formatter.stream(tokens, &block)

        yield "</code></pre></div>" if @wrap_css_class
      end
    end
  end
end
