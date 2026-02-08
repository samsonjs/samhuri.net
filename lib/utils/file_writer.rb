require 'fileutils'

module Pressa
  module Utils
    class FileWriter
      def self.write(path:, content:, permissions: 0o644)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, content, mode: 'w')
        File.chmod(permissions, path)
      end

      def self.write_data(path:, data:, permissions: 0o644)
        FileUtils.mkdir_p(File.dirname(path))

        File.binwrite(path, data)
        File.chmod(permissions, path)
      end
    end
  end
end
