require_relative '../../test_helper'

class Aggregate::Attribute::BitfieldTest < ActiveSupport::TestCase

  should "handle bitfield" do
    ad = Aggregate::AttributeHandler.factory("testme", :bitfield, limit: 4)

    result = ad.from_value("tf t")
    assert_equal Aggregate::Bitfield.limit(4).new("tf t"), result
    assert_equal true, result[0]
    assert_equal false, result[1]
    assert_equal nil, result[2]
    assert_equal true, result[3]

    assert_equal Aggregate::Bitfield.limit(4).new("tf t"), ad.from_store("tf t")
    assert_equal "tf t",    ad.to_store(Aggregate::Bitfield.limit(4).new("tf t"))
  end

  should "provide a default" do
    ad = Aggregate::AttributeHandler.factory("testme", :bitfield, limit: 4)

    assert_equal Aggregate::Bitfield.limit(4).new(""), ad.default

  end

  should "be valid" do
    ad = Aggregate::AttributeHandler.factory("testme", :bitfield, limit: 4)
    assert_equal [], ad.validation_errors("")
  end

end
