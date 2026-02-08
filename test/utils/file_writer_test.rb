require "test_helper"
require "tmpdir"

class Pressa::Utils::FileWriterTest < Minitest::Test
  def test_write_creates_directories_writes_content_and_sets_permissions
    Dir.mktmpdir do |dir|
      path = File.join(dir, "nested", "file.txt")
      Pressa::Utils::FileWriter.write(path:, content: "hello", permissions: 0o600)

      assert_equal("hello", File.read(path))
      assert_equal("600", format("%o", File.stat(path).mode & 0o777))
    end
  end

  def test_write_data_writes_binary_content_and_sets_permissions
    Dir.mktmpdir do |dir|
      path = File.join(dir, "nested", "data.bin")
      data = "\x00\xFFabc".b
      Pressa::Utils::FileWriter.write_data(path:, data:, permissions: 0o640)

      assert_equal(data, File.binread(path))
      assert_equal("640", format("%o", File.stat(path).mode & 0o777))
    end
  end
end
