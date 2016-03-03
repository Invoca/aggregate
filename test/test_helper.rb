# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails/test_help"
require "invoca/utils"
require "rr"
require "shoulda"
require "minitest/unit"
require "pry"

def sample_passport
  Passport.create!(
    name: "Millie",
    gender: :female,
    birthdate: Time.parse("2011-8-11"),
    city: "Santa Barbara",
    state: "California"
  )
end
