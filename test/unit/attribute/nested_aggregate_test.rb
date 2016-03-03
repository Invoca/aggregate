require_relative '../../test_helper'

class Aggregate::Attribute::NestedAggregateTest < ActiveSupport::TestCase

  class TestNestedAggregate
    attr_accessor :value, :callback

    def initialize(value)
      @value = value
    end

    def self.from_store(value)
      new("self.from_store(#{value})")
    end

    def to_store
      "to_store(#{value})"
    end

    def errors
      [
        [:cats, "have wiskers"],
        [:dogs, "do too"]
      ]
    end

    def valid?
      false
    end

  end

  should "handle aggregates" do
    ad = Aggregate::AttributeHandler.factory("testme", TestNestedAggregate.name, {})

    v = ad.from_value("test_value")
    assert v.is_a?(TestNestedAggregate)
    assert_equal "test_value", v.value

    v = ad.from_store("test_method")
    assert_equal "self.from_store(test_method)",   v.value
    assert_equal TestNestedAggregate,              ad.new("foo").class
  end

  should "delegate to the class for validation" do
    ad = Aggregate::AttributeHandler.factory("testme", TestNestedAggregate.name, {})
    expected = ["cats have wiskers", "dogs do too"]
    assert_equal expected, ad.validation_errors(TestNestedAggregate.new("test_value"))
  end
end
