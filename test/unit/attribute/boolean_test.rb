# frozen_string_literal: true

require_relative '../../test_helper'

class Aggregate::Attribute::BooleanTest < ActiveSupport::TestCase

  should "handle booleans" do
    ad = Aggregate::AttributeHandler.factory("testme", :boolean, {})
    assert_equal true,   ad.from_value("1")
    assert_equal true,   ad.from_value("t")
    assert_equal true,   ad.from_value("T")
    assert_equal true,   ad.from_value("true")
    assert_equal true,   ad.from_value("TRUE")

    assert_equal false,   ad.from_value("0")
    assert_equal false,   ad.from_value("f")
    assert_equal false,   ad.from_value("F")
    assert_equal false,   ad.from_value("false")
    assert_equal false,   ad.from_value("FALSE")

    assert_equal false,   ad.from_store(false)
    assert_equal true,    ad.to_store(true)

    assert_equal TrueClass, ad.new(true).class
  end

end
