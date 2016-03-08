require_relative '../../test_helper'

class Aggregate::Attribute::EnumTest < ActiveSupport::TestCase

  should "handle enums" do
    ad = Aggregate::AttributeHandler.factory("testme", :enum, {})
    assert_equal :abc, ad.from_value("abc")
    assert_equal :abc, ad.from_store("abc")
    assert_equal "abc", ad.to_store(:abc)
    assert_equal Symbol, ad.new(:abc).class
  end

end
