require_relative '../test_helper'

class Aggregate::AttributeHandlerTest < ActiveSupport::TestCase

  class TestNestedAggregate
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def self.from_store(value)
      "self.from_store(#{value})"
    end

    def to_store
      "to_store(#{value})"
    end

    def valid?
      false
    end

  end

  context "aggregate attribute definitions" do
    should "allow defaults" do
      ad = Aggregate::AttributeHandler.factory("testme", "string", {})
      assert_equal nil, ad.default

      ad = Aggregate::AttributeHandler.factory("testme", "string", default: "abc")
      assert_equal "abc", ad.default

      ad = Aggregate::AttributeHandler.factory("testme", "string", default: -> { "def" })
      assert_equal "def", ad.default
    end

    should "report force validation iff the option is passed" do
      ad = Aggregate::AttributeHandler.factory("testme", TestNestedAggregate.name, {})
      assert !ad.force_validation?

      ad = Aggregate::AttributeHandler.factory("testme", TestNestedAggregate.name, force_validation: true)
      assert ad.force_validation?
    end

    should "construct has_many objects" do
      has_many = Aggregate::AttributeHandler.has_many_factory(:foo, :string, {})
      assert_equal "Aggregate::Attribute::List", has_many.class.name
      assert_equal "Aggregate::Attribute::String", has_many.element_helper.class.name
    end

    should "construct belongs to objects" do
      belongs_to = Aggregate::AttributeHandler.belongs_to_factory(:foo, {})
      assert_equal "Aggregate::Attribute::ForeignKey", belongs_to.class.to_s
    end
  end

end
