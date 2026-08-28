source "https://rubygems.org"
ruby file: ".ruby-version"

gem "phlex", "~> 2.3"
gem "kramdown", "~> 2.5"
gem "kramdown-parser-gfm", "~> 1.1"
gem "rouge", "~> 5.0"
gem "dry-struct", "~> 1.8"
gem "builder", "~> 3.3"
gem "bake", "~> 0.20"

# The Pressa web app under web/. It shares this bundle with bake on purpose:
# it shells out to bin/post-link, which runs `bundle exec bake`, and a separate
# Gemfile would leave BUNDLE_GEMFILE pointing at the wrong one in the child.
group :web do
  gem "sinatra", "~> 4.1"
  gem "puma", "~> 6.6"
  gem "super_good-csrf_protection", "~> 0.2"
end

group :development, :test do
  gem "guard", "~> 2.18"
  gem "minitest", "~> 6.0"
  gem "rack-test", "~> 2.2"
  gem "standard", "~> 1.52"
end
