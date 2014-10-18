require 'htmlentities'
require 'open-uri'

class WebTitleFinder

  def find_title(url)
    body = open(url).read
    lines = body.split(/[\r\n]+/)
    title_line = lines.grep(/<title/).first.strip
    html_title = title_line.gsub(/\s*<\/?title[^>]*>\s*/, '')
    HTMLEntities.new.decode(html_title)
  rescue
    nil
  end

end
