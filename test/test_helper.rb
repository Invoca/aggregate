# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "invoca/utils"
require "rr"
require "shoulda"
require "minitest/unit"
require "pry"

# Remove both of these before checkin.
require File.expand_path(File.dirname(__FILE__) + "/helpers/test_unit_assertions_overrides")
require File.expand_path(File.dirname(__FILE__) + "/helpers/time_now_override")

# See if we can stub time instead of overriding it....
def overrides_time_zone new_time_zone = Rails.configuration.time_zone
  old_time_zone, Time.zone = Time.zone, new_time_zone
  yield
ensure
  Time.zone = old_time_zone
end

# See if we can stub this instead of overriding it.
def overrides_time new_override = Time.now
  old_override, Time.now_override = Time.now_override, new_override
  yield
ensure
  Time.now_override = old_override
end


def sample_passport
  Passport.create!(
    name: "Millie",
    gender: :female,
    birthdate: Time.parse("2011-8-11"),
    city: "Santa Barbara",
    state: "California"
  )
end