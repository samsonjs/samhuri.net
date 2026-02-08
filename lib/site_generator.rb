require "fileutils"
require_relative "utils/file_writer"

module Pressa
  class SiteGenerator
    attr_reader :site

    def initialize(site:)
      @site = site
    end

    def generate(source_path:, target_path:)
      validate_paths!(source_path:, target_path:)

      FileUtils.rm_rf(target_path)
      FileUtils.mkdir_p(target_path)

      site.plugins.each { |plugin| plugin.setup(site:, source_path:) }

      site.plugins.each { |plugin| plugin.render(site:, target_path:) }

      copy_static_files(source_path, target_path)
      process_public_directory(source_path, target_path)
    end

    private

    def validate_paths!(source_path:, target_path:)
      source_abs = absolute_path(source_path)
      target_abs = absolute_path(target_path)
      return unless contains_path?(container: target_abs, path: source_abs)

      raise ArgumentError, "target_path must not be the same as or contain source_path"
    end

    def absolute_path(path)
      File.exist?(path) ? File.realpath(path) : File.expand_path(path)
    end

    def contains_path?(container:, path:)
      path == container || path.start_with?("#{container}#{File::SEPARATOR}")
    end

    def copy_static_files(source_path, target_path)
      public_dir = File.join(source_path, "public")
      return unless Dir.exist?(public_dir)

      Dir.glob(File.join(public_dir, "**", "*"), File::FNM_DOTMATCH).each do |source_file|
        next if File.directory?(source_file)
        next if skip_file?(source_file)

        filename = File.basename(source_file)
        ext = File.extname(source_file)[1..]

        if can_render?(filename, ext)
          next
        end

        relative_path = source_file.sub("#{public_dir}/", "")
        target_file = File.join(target_path, relative_path)

        FileUtils.mkdir_p(File.dirname(target_file))
        FileUtils.cp(source_file, target_file)
      end
    end

    def can_render?(filename, ext)
      site.renderers.any? { |renderer| renderer.can_render_file?(filename:, extension: ext) }
    end

    def process_public_directory(source_path, target_path)
      public_dir = File.join(source_path, "public")
      return unless Dir.exist?(public_dir)

      site.renderers.each do |renderer|
        Dir.glob(File.join(public_dir, "**", "*"), File::FNM_DOTMATCH).each do |source_file|
          next if File.directory?(source_file)
          next if skip_file?(source_file)

          filename = File.basename(source_file)
          ext = File.extname(source_file)[1..]

          if renderer.can_render_file?(filename:, extension: ext)
            dir_name = File.dirname(source_file)
            relative_path = if dir_name == public_dir
              ""
            else
              dir_name.sub("#{public_dir}/", "")
            end
            target_dir = File.join(target_path, relative_path)

            renderer.render(site:, file_path: source_file, target_dir:)
          end
        end
      end
    end

    def skip_file?(source_file)
      basename = File.basename(source_file)
      basename.start_with?(".")
    end
  end
end
