require_relative '../../test_helper'

class Aggregate::Attribute::ForeignKeyTest < ActiveSupport::TestCase


  context "foreign_key" do
    should "handle foreign_keys" do
      passport = sample_passport

      ad = Aggregate::AttributeHandler.belongs_to_factory("testme", {:class_name=>"Passport"})

      assert_equal passport,         ad.from_value(passport)
      assert_equal passport,         ad.from_value(passport.id)
      assert_equal passport,         ad.from_store(passport.id)
      assert_equal passport.id,      ad.to_store(passport)

      assert_equal nil,             ad.from_value(nil)
      assert_equal nil,             ad.from_store(nil)
      assert_equal nil,             ad.to_store(nil)
    end
  end

end
