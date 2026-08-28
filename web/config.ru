lib_path = File.expand_path("../lib", __dir__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

require "pressa/web/app"

run Pressa::Web::App
