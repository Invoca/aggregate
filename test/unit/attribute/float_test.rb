require_relative '../../test_helper'

class Aggregate::Attribute::FloatTest < ActiveSupport::TestCase

  should "handle floats" do
    ad = Aggregate::AttributeHandler.factory("testme", :float, {})
    assert_equal "1.0",  ad.from_value("1.0")
    assert_equal 2.4,    ad.from_store("2.4")
    assert_equal 5.5,    ad.to_store("5.5")

    assert_equal "3.5", ad.from_value("3.5")
    assert_equal Float, ad.new(0.0).class
  end

end
