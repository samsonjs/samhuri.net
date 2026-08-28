require "cgi"
require "net/http"
require "uri"

module Pressa
  # Best-effort scraper for OpenGraph metadata on a linked page: an Image for
  # link posts, plus the title and description used to prefill the link form.
  # Never raises: network failures, timeouts, and missing tags all just resolve
  # to nil fields so post creation never blocks on a flaky or slow third-party
  # site.
  class OpenGraph
    Result = Data.define(:title, :description, :image)

    USER_AGENT = "samhuri.net-link-preview/1.0".freeze
    MAX_REDIRECTS = 5
    TITLE_ELEMENT = /<title[^>]*>([^<]*)<\/title>/i

    def self.fetch(url, http_get: method(:http_get))
      html = http_get.call(url)
      return nil if html.nil?

      extract(html, base_url: url)
    rescue
      nil
    end

    def self.extract(html, base_url:)
      title = text_field(html, "og:title") || clean(html[TITLE_ELEMENT, 1])
      description = text_field(html, "og:description") || text_field(html, "description")
      image = meta_content(html, "og:image") || meta_content(html, "twitter:image")
      return nil if title.nil? && description.nil? && image.nil?

      Result.new(title:, description:, image: image && resolve(image, base_url:))
    end

    def self.text_field(html, property)
      clean(meta_content(html, property))
    end

    def self.meta_content(html, property)
      pattern = /<meta\s+[^>]*(?:property|name)\s*=\s*["']#{Regexp.escape(property)}["'][^>]*>/i
      tag = html[pattern]
      return nil unless tag

      content = tag[/content\s*=\s*["']([^"']*)["']/i, 1]
      content&.strip&.then { |value| value.empty? ? nil : value }
    end

    def self.clean(value)
      return nil if value.nil?

      unescaped = CGI.unescapeHTML(value).strip
      unescaped.empty? ? nil : unescaped
    end

    def self.resolve(image, base_url:)
      URI.join(base_url, image).to_s
    rescue URI::InvalidURIError, URI::InvalidComponentError
      image
    end

    def self.http_get(url, redirects_left: MAX_REDIRECTS)
      return nil if redirects_left < 0

      uri = URI.parse(url)
      return nil unless uri.is_a?(URI::HTTP)

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 5) do |http|
        response = http.get(uri.request_uri, "User-Agent" => USER_AGENT)

        case response
        when Net::HTTPSuccess
          response.body
        when Net::HTTPRedirection
          location = response["location"]
          return nil unless location

          http_get(URI.join(url, location).to_s, redirects_left: redirects_left - 1)
        end
      end
    end
  end
end
