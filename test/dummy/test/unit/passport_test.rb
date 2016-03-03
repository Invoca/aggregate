require_relative '../../../test_helper'

class PassportTest < ActiveSupport::TestCase
  context "initialization" do
    should "be able to constuct a class with aggregates" do
      passport = Passport.create!(
        name: "Millie",
        gender: :female,
        birthdate: Time.parse("2011-8-11"),
        city: "Santa Barbara",
        state: "California"
      )
    end

    should "verify that the required attributes are passed" do
      passport = Passport.new

      assert !passport.valid?
      assert_equal ["Gender must be set",
                    "City must be set",
                    "State must be set",
                    "Birthdate must be set"], passport.errors.full_messages
    end

    should "be able to build aggregates" do
      passport = sample_passport

      passport.foreign_visits = [ ForeignVisit.new(country: "Canada"), ForeignVisit.new(country: "Mexico") ]

      passport.save!
      passport = Passport.find(passport.id)

      assert_equal ["Canada", "Mexico"], passport.foreign_visits.map(&:country)
    end
  end
end
