require_relative '../../test_helper'

class Aggregate::Attribute::BaseTest < ActiveSupport::TestCase

  context "aggregate attribute definitions" do
    context "constructor" do
      should "go right" do
        ad = Aggregate::AttributeHandler.factory("testme", "string", {})
        assert_equal "testme", ad.name
        assert_equal({},       ad.options)
        assert_equal String,   ad.new('').class
      end

      should "convert arguments to strings" do
        ad = Aggregate::AttributeHandler.factory(:testme, :string, {})
        assert_equal "testme", ad.name
      end

      should "validate constructor arguments" do
        assert_raises(ArgumentError) { Aggregate::AttributeHandler.factory(:testme, :string, not_an_option: false) }
      end
    end

    context "validations" do
      should "allow nil if not required" do
        ad = Aggregate::AttributeHandler.factory("testme", :decimal, {})
        expected = []
        assert_equal expected, ad.validation_errors(nil)
      end

      should "enforce required fields" do
        ad = Aggregate::AttributeHandler.factory("testme", :decimal, required: true)
        expected = ["must be set"]
        assert_equal expected, ad.validation_errors(nil)
      end

      should "enforce limit" do
        ad = Aggregate::AttributeHandler.factory("testme", :enum, limit: [:red, :blue, :green])
        expected = ["is not in list (:azure not in [:red, :blue, :green])"]
        assert_equal expected, ad.validation_errors(:azure)
      end
    end

    should "allow defaults" do
      ad = Aggregate::AttributeHandler.factory("testme", "string", {})
      assert_equal nil, ad.default

      ad = Aggregate::AttributeHandler.factory("testme", "string", default: "abc")
      assert_equal "abc", ad.default

      ad = Aggregate::AttributeHandler.factory("testme", "string", default: -> { "def" })
      assert_equal "def", ad.default
    end

    should "report force validation iff the option is passed" do
      ad = Aggregate::AttributeHandler.factory("testme", "string", {})
      assert !ad.force_validation?

      ad = Aggregate::AttributeHandler.factory("testme", "string", force_validation: true)
      assert ad.force_validation?
    end
  end
end
