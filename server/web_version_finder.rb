require 'open-uri'

class WebVersionFinder

  DEFAULT_URL = 'https://samhuri.net/version.txt'

  def find_version(url = nil)
    open(url || DEFAULT_URL).read.strip
  end

end
