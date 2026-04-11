LIB_PATH = File.expand_path("lib", __dir__).freeze
$LOAD_PATH.unshift(LIB_PATH) unless $LOAD_PATH.include?(LIB_PATH)

# Default task: run coverage and lint.
def default
  call("quality:coverage")
  call("quality:lint")
end
