require_relative '../../../test_helper'

class PassportTest < ActiveSupport::TestCase
  context "initialization" do
    should "be able to constuct a class with aggregates" do
      Passport.create!(
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

      passport.foreign_visits = [ForeignVisit.new(country: "Canada"), ForeignVisit.new(country: "Mexico")]

      passport.save!
      passport = Passport.find(passport.id)

      assert_equal %w(Canada Mexico), passport.foreign_visits.map(&:country)
    end

    should "be able to access bitfields" do
      passport = sample_passport

      passport.stamps[0] = true
      passport.stamps[5] = false

      passport.save!
      passport = Passport.find(passport.id)

      assert_equal true, passport.stamps[0]
      assert_equal false, passport.stamps[5]
      assert_equal nil, passport.stamps[4]

    end

    should "not write default values" do
      passport = sample_passport

      passport.foreign_visits = [ForeignVisit.new(country: "Canada"), ForeignVisit.new(country: "Mexico")]

      passport.save!

      expected =
        {
          "birthdate"=>"Thu, 11 Aug 2011 07:00:00 -0000",
          "city"=>"Santa Barbara",
          "foreign_visits"=>[{"country"=>"Canada"},{"country"=>"Mexico"}],
          "gender"=>"female",
          "state"=>"California"
        }

      assert_equal expected, passport.to_store

    end
  end
end
