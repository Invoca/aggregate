# frozen_string_literal: true

require_relative '../../test_helper'

class Aggregate::Attribute::StringTest < ActiveSupport::TestCase

  should "handle strings" do
    ad = Aggregate::AttributeHandler.factory("testme", :string, {})
    assert_equal "abc", ad.from_value("abc")
    assert_equal "abc", ad.from_store("abc")
    assert_equal "abc", ad.to_store("abc")

    assert_equal "1", ad.from_value(1)
  end

  should "enforce maximum size" do
    ad = Aggregate::AttributeHandler.factory("testme", :string, size: 100)
    expected = ["String is too long (maximum is 100 characters)"]
    assert_equal expected, ad.validation_errors("1" * 101)
  end
end
