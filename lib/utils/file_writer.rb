require 'fileutils'
require_relative 'html_formatter'

module Pressa
  module Utils
    class FileWriter
      def self.write(path:, content:, permissions: 0o644)
        FileUtils.mkdir_p(File.dirname(path))

        formatted_content = if path.end_with?('.html')
                              HtmlFormatter.format(content)
                            else
                              content
                            end

        File.write(path, formatted_content, mode: 'w')
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
