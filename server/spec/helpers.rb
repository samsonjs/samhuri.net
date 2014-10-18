module Helpers

  def increasing?(list)
    comparisons(list).all? { |x| x && x <= 0 }
  end

  def decreasing?(list)
    comparisons(list).all? { |x| x && x >= 0 }
  end

  def comparisons(list)
    x = list.first
    list.drop(1).map do |y|
      x <=> y
    end
  end

  def git_bare?(dir)
    if File.exist?(File.join(dir, '.git'))
      false
    elsif File.exist?(File.join(dir, 'HEAD'))
      true
    else
      raise "what is this dir? #{dir} #{Dir[dir + '/*'].join(', ')}"
    end
  end

  def git_sha(dir)
    if git_bare?(dir)
      `cd '#{dir}' && cat "$(cut -d' ' -f2 HEAD)"`.strip
    else
      `cd '#{dir}' && git log -n1`.split[1].strip
    end
  end

  def git_reset_hard(dir, ref = nil)
    if git_bare?(dir)
      raise 'git_reset_hard does not support bare repos ' + dir + ' -- ' + ref.to_s
    else
      args = ref ? "'#{ref}'" : ''
      `cd '#{dir}' && git reset --hard #{args}`
    end
  end

  class TitleFinder
    attr_accessor :title
    def initialize(title)
      @title = title
    end
    def find_title(url) @title end
  end

  def mock_title_finder(title)
    TitleFinder.new(title)
  end

  class VersionFinder
    attr_accessor :version
    def initialize(version)
      @version = version
    end
    def find_version(url = nil)
      @version
    end
  end

  def mock_version_finder(version)
    VersionFinder.new(version)
  end

end
