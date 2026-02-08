module Pressa
  class Plugin
    def setup(site:, source_path:)
      raise NotImplementedError, "#{self.class}#setup must be implemented"
    end

    def render(site:, target_path:)
      raise NotImplementedError, "#{self.class}#render must be implemented"
    end
  end
end
