# frozen_string_literal: true

source "https://rubygems.org"
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"

gem 'encryptor',            '3.0.0'
gem 'hobo_support',         '2.0.1',  git: 'git@github.com:Invoca/hobosupport',           ref: 'b9086322274b474a2b5bae507c4885e55d4aa050'
gem 'large_text_field',               git: 'git@github.com:Invoca/large_text_field.git',  ref: '2efc950395352bf8b7f45891122f6bc42b171526'
gem 'protected_attributes', '1.1.3'

group :development do
  gem 'invoca-utils', '0.0.2'
  gem 'sqlite3'
end

group :test do
  gem 'minitest',  '~> 5.1'
  gem 'pry'
  gem 'rr',        '1.1.2'
  gem 'shoulda',   '3.5.0'
  gem 'test-unit', '3.1.3'
  gem 'test_after_commit'
end

gem 'rubocop', require: false
