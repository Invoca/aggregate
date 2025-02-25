# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "aggregate"

require File.expand_path('dummy/config/environment.rb', __dir__)
require "rails/test_help"
require "invoca/utils"
require 'rspec/mocks/minitest_integration'
require 'rspec/expectations/minitest_integration'
require "shoulda"
require "minitest/unit"
require "pry"

require "minitest/reporters"
Minitest::Reporters.use! [
  Minitest::Reporters::ProgressReporter.new,
  Minitest::Reporters::JUnitReporter.new(ENV['JUNIT_OUTPUT'].presence || 'test/reports/current')
]

Rails.backtrace_cleaner.remove_silencers!
# Rails.backtrace_cleaner.add_silencer { |line| line =~ /active_support/}
# Rails.backtrace_cleaner.add_silencer { |line| line =~ /shoulda/}

def sample_passport
  Passport.create!(
    name: "Millie",
    gender: :female,
    birthdate: Time.parse("2011-8-11"),
    city: "Santa Barbara",
    state: "California"
  )
end

def assert_false(actual, message = nil)
  assert_equal false, actual, message
end
