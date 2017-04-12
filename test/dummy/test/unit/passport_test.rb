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

    should "be able to save and restore empty bitfields" do
      passport = sample_passport

      passport.save!
      passport = Passport.find(passport.id)

      passport.stamps[0] = true
      assert_equal true, passport.stamps[0]
    end

    should "not write default values" do
      passport = sample_passport

      passport.foreign_visits = [ForeignVisit.new(country: "Canada"), ForeignVisit.new(country: "Mexico")]

      passport.save!

      expected =
        {
          "birthdate"=>Time.parse("2011-8-11"),
          "city"=>"Santa Barbara",
          "foreign_visits"=>[{"country"=>"Canada"},{"country"=>"Mexico"}],
          "gender"=>"female",
          "stamps" => nil,
          "state"=>"California",
          "weight" => "100"
        }

      assert_equal expected, passport.to_store

      # Should re-assert the defaults when loaded.
      passport = Passport.find(passport.id)
      assert_equal 100, passport.weight
    end

    context "encrypted field" do
      setup do
        Aggregate.reset
        @secret_key = SecureRandom.random_bytes(32)
        @iv =SecureRandom.random_bytes(12)
      end

      should "fail encryption if secret isn't set" do
        assert_raise(ArgumentError,/must specify a key/ ) do
          @passport = Passport.create!(
            name: "Millie",
            gender: :female,
            birthdate: Time.parse("2011-8-11"),
            city: "Santa Barbara",
            state: "California",
            password: "ThisIsATestPassword"
          )
        end
      end

      should "encrypt password when secret is available" do
        Aggregate.configure do |config|
          config.encryption_key = @secret_key
          config.iv = @iv
        end

        @passport = Passport.create!(
          name: "Millie",
          gender: :female,
          birthdate: Time.parse("2011-8-11"),
          city: "Santa Barbara",
          state: "California",
          password: "ThisIsATestPassword"
        )
      end

      should "decrypt password when secret is available" do

      end
    end
  end
end
