# frozen_string_literal: true

require_relative '../../test_helper'

class Aggregate::Attribute::BitfieldTest < ActiveSupport::TestCase

  setup do
    @ad = Aggregate::AttributeHandler.factory("testme", :bitfield, limit: 4)
    @default_bitfield_options = { mapping: { 't' => true, 'f' => false, ' ' => nil }, default: nil }
  end

  should "handle bitfields as booleans by default" do
    result = @ad.from_value("tf t")
    assert_equal Aggregate::Bitfield.limit(4).new("tf t", @default_bitfield_options), result
    assert_equal true, result[0]
    assert_equal false, result[1]
    assert_nil result[2]
    assert_equal true, result[3]

    assert_equal Aggregate::Bitfield.limit(4).new("tf t", @default_bitfield_options), @ad.from_store("tf t")
    assert_equal "tf t", @ad.to_store(Aggregate::Bitfield.limit(4).new("tf t", @default_bitfield_options))
  end

  should "allow custom mapping and default values" do
    mapping = { 'a' => :awesome, 'p' => :pizza }
    default = :pizza
    ad = Aggregate::AttributeHandler.factory("testme", :bitfield, limit: 4, mapping: mapping, default: default)

    bitfield = ad.default
    bitfield[2] = :awesome
    assert_equal "ppa", bitfield.to_s
    assert_equal Aggregate::Bitfield.limit(4).new("ppa", mapping: mapping, default: :pizza), bitfield
  end

  should "provide a default" do
    expected_default = Aggregate::Bitfield.limit(4).new("", @default_bitfield_options)
    assert_equal expected_default, @ad.default
  end

  should "be valid" do
    assert_equal [], @ad.validation_errors("")
  end

  context ".available_options" do
    should "support limit, mapping, and default" do
      available_options = @ad.class.available_options
      assert([:limit, :mapping, :default].all? { |option| option.in?(available_options) })
    end
  end

  should "raise ArgumentError if default value is not included in mapping" do
    assert_raises ArgumentError, "default value not provided in mapping" do
      Aggregate::AttributeHandler.factory("testme", :bitfield, limit: 4, default: :default)
    end
  end

  should "raise ArgumentError if mapping provided is not a hash" do
    assert_raises ArgumentError, "mapping must be provided as a Hash" do
      Aggregate::AttributeHandler.factory("testme", :bitfield, limit: 4, mapping: [])
    end
  end

  should "raise ArgumentError if mapping values are not unique" do
    assert_raises ArgumentError, "mapping must have unique values" do
      Aggregate::AttributeHandler.factory("testme", :bitfield, limit: 4, mapping: { 't' => true, 'f' => true, ' ' => nil })
    end
  end
end
