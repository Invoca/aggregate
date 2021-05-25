# frozen_string_literal: true

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

      assert_equal %w[Canada Mexico], passport.foreign_visits.map(&:country)
    end

    should "be able to access bitfields" do
      passport = sample_passport

      passport.stamps[0] = true
      passport.stamps[5] = false

      passport.save!
      passport = Passport.find(passport.id)

      assert_equal true, passport.stamps[0]
      assert_equal false, passport.stamps[5]
      assert_nil passport.stamps[4]
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
          "birthdate"      => Time.parse("2011-8-11"),
          "city"           => "Santa Barbara",
          "foreign_visits" => [{ "country" => "Canada" }, { "country" => "Mexico" }],
          "gender"         => "female",
          "state"          => "California",
          "weight"         => "100.0"
        }

      assert_equal expected, passport.to_store

      # Should re-assert the defaults when loaded.
      passport = Passport.find(passport.id)
      assert_equal 100, passport.weight
    end

    context "encrypted field" do
      setup do
        Aggregate.reset
        @secret_key = Base64.strict_encode64(SecureRandom.random_bytes(32))
        # keys:  [ "\x11\xD2\xA2\x8F\x8E\xC9!i\xF8\xEEr\x03A\xF3\xA7QvY\x8F\xBCzw\xA7\xE3\xA7;\x86\xAE\xD3\x13\x9F/", "\xCAE\x1F\xC7<W\xEA\xB4[\xE4'\xCA'\a\x17&\xF2I\x87\x1A\x17\x9B?\x86\xB1A\a%9\xEBZ@", "#\x13G\xFA\xE5\"\xC0\xCAzL\xE7\x9F\xB0=[\x17>\xF33\xC2\x85\xBF\x16%\a\xE8z:]\xCA1D"
        @secret_key_list = ["EdKij47JIWn47nIDQfOnUXZZj7x6d6fjpzuGrtMTny8=",
                            "ykUfxzxX6rRb5CfKJwcXJvJJhxoXmz+GsUEHJTnrWkA=",
                            "IxNH+uUiwMp6TOefsD1bFz7zM8KFvxYlB+h6Ol3KMUQ="]
      end

      should "fail encryption if secret isn't set" do
        assert_raise(Aggregate::EncryptionError, /must specify a key for encryption/) do
          @passport = Passport.create!(
            name: "Millie",
            gender: :female,
            birthdate: Time.parse("2011-8-11"),
            city: "Santa Barbara",
            state: "California",
            password: "ThisIsATestPassword!"
          )
        end
      end

      should "encrypt and decrypt password when encryption_key is available" do
        Aggregate.configure do |config|
          config.keys_list = @secret_key
        end

        passport = Passport.create!(
          name: "Millie",
          gender: :female,
          birthdate: Time.parse("2011-8-11"),
          city: "Santa Barbara",
          state: "California",
          password: "ThisIsATestPassword!@#$%^&*()_-+=1234567890qwertyuiop[]\asdfdghjkl;'zxcvbnm,.//*-~`'"
        )

        passport = Passport.find(passport.id)
        assert_equal "ThisIsATestPassword!@#$%^&*()_-+=1234567890qwertyuiop[]\asdfdghjkl;'zxcvbnm,.//*-~`'", passport.password

        Aggregate.configure do |config|
          config.keys_list = Base64.strict_encode64(SecureRandom.random_bytes(32))
        end

        passport = Passport.find(passport.id)
        assert_raise(Aggregate::EncryptionError, /could not decrypt password because the correct decryption key is not found/) do
          passport.password
        end
      end

      should "raise when decrypting password when key is not available" do
        Aggregate.configure do |config|
          config.keys_list = @secret_key
        end

        passport = Passport.create!(
          name: "Millie",
          gender: :female,
          birthdate: Time.parse("2011-8-11"),
          city: "Santa Barbara",
          state: "California",
          password: "ThisIsATestPassword!@#$%^&*()_-+=1234567890qwertyuiop[]\asdfdghjkl;'zxcvbnm,.//*-~`'"
        )

        Aggregate.configure do |config|
          config.keys_list = nil
        end

        passport = Passport.find(passport.id)
        assert_raise(Aggregate::EncryptionError, /must specify a key for decryption/) do
          passport.password
        end
      end

      should "decrypt password when secret hash is available" do
        Aggregate.configure do |config|
          config.keys_list = @secret_key_list
        end

        passport = Passport.create!(
          name: "Millie",
          gender: :female,
          birthdate: Time.parse("2011-8-11"),
          city: "Santa Barbara",
          state: "California",
          password: "ThisIsATestPassword!@#$%^&*()_-+=1234567890qwertyuiop[]\asdfdghjkl;'zxcvbnm,.//*-~`'"
        )

        assert_equal "ThisIsATestPassword!@#$%^&*()_-+=1234567890qwertyuiop[]\asdfdghjkl;'zxcvbnm,.//*-~`'", passport.password
      end

      should "correctly store JSON with properly hashed fields for encrypted data" do
        stub(SecureRandom).random_bytes(12) { "\x8D\xE8E\x95\xB85\xF9~|$n#" }
        expected_json = "{\\\"encrypted_data\\\":\\\"ng3gws8rbrUB+fjMQEl6ALUgVxfGFZf/BRyucnyYGrI9Imbkh0ppMitF0nxboXNj8uXWZtLU2u+uE6/Q4vhIbG9eKGtvzWUbWmSxeG+rxSJvM477WNf1vknsZ5UPkQMOTG+1\\\",\\\"initilization_vector\\\":\\\"jehFlbg1+X58JG4j\\\"}\"}"

        Aggregate.configure do |config|
          config.keys_list = @secret_key_list
        end

        passport = Passport.create!(
          name: "Millie",
          gender: :female,
          birthdate: Time.parse("2011-8-11"),
          city: "Santa Barbara",
          state: "California",
          password: "ThisIsATestPassword!@#$%^&*()_-+=1234567890qwertyuiop[]\asdfdghjkl;'zxcvbnm,.//*-~`'"
        )

        assert passport.aggregate_store.include?(expected_json)
        assert_equal "ThisIsATestPassword!@#$%^&*()_-+=1234567890qwertyuiop[]\asdfdghjkl;'zxcvbnm,.//*-~`'", passport.password
      end
    end
  end
end
