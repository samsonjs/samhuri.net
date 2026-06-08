module Pressa
  # Pure git-related decisions for the coverage tasks. The actual git commands
  # run in bake.rb; this just decides which remote to treat as canonical.
  module Git
    class Error < StandardError; end

    # Remotes are preferred in this order when nothing else picks one.
    DEFAULT_REMOTE_PREFERENCE = %w[github origin].freeze

    module_function

    # Pick the remote to resolve the coverage baseline against. An explicit
    # upstream wins; otherwise fall back through the preference list, then to
    # the first configured remote.
    def choose_remote(remotes:, upstream_remote: nil, preference: DEFAULT_REMOTE_PREFERENCE)
      return upstream_remote unless upstream_remote.to_s.empty?

      raise Error, "no git remotes configured; pass baseline=<ref>." if remotes.empty?

      preference.find { |name| remotes.include?(name) } || remotes.first
    end
  end
end
