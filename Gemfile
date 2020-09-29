# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

ruby "2.7.1"

gem "csv"
gem "terminal-table"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "ruby-debug-ide", require: false
end
