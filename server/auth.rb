require 'json'

class Auth
  def initialize(filename)
    @credentials = JSON.parse(File.read(filename))
  end

  def authenticated?(username, password)
    @credentials['username'] == username && @credentials['password'] == password
  end
end
