require_relative '../../test_helper'

class Aggregate::Attribute::IntegerTest < ActiveSupport::TestCase

  should "handle integer" do
    ad = Aggregate::AttributeHandler.factory("testme", :integer, {})
    assert_equal 1,   ad.from_value("1")
    assert_equal 2,   ad.from_store("2")
    assert_equal "3", ad.to_store("3")

    assert_equal 3,   ad.from_value(3)
    assert_equal Integer, ad.new(3).class
  end
end
