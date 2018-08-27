# frozen_string_literal: true

require_relative '../../test_helper'

class Aggregate::Attribute::DecimalTest < ActiveSupport::TestCase

  should "handle decimal" do
    ad = Aggregate::AttributeHandler.factory("testme", :decimal, {})
    assert_equal 1.0, ad.from_value("1.0")
    assert_equal 2.4, ad.from_store("2.4")
    assert_equal "5.5", ad.to_store("5.5")
    assert_equal "10.05412123", ad.to_store("10.05412123")

    assert_equal 3.5, ad.from_value("3.5")
    assert_equal BigDecimal, ad.new(3.5).class
  end

  should "accept option of scale" do
    ad = Aggregate::AttributeHandler.factory("testme", :decimal, scale: 2)
    assert_equal "10.05", ad.to_store("10.05412123")
    assert_equal 10.05, ad.load("10.05412123")
  end
end
