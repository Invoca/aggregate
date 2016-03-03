require_relative '../../test_helper'

class Aggregate::Attribute::ListTest < ActiveSupport::TestCase

  should "default to an empty list for nils" do
    ad = Aggregate::AttributeHandler.has_many_factory("testme", "string", {})
    assert_equal [], ad.from_value(nil)
    assert_equal [], ad.from_store(nil)
    assert_equal [], ad.to_store(nil)
  end

  should "raise if it was not passed a list" do
    ad = Aggregate::AttributeHandler.has_many_factory("testme", "string", {})
    assert_raise(RuntimeError) { ad.from_value(1) }
  end

  should "handle basic marshalling" do
    ad = Aggregate::AttributeHandler.has_many_factory("testme", "string", {})

    assert_equal ["manny","moe","jack"], ad.from_value( ["manny","moe","jack"] )
    assert_equal ["manny","moe","jack"], ad.from_value( [:manny,"moe","jack"] )

    assert_equal ["manny","moe","jack"], ad.to_store( ["manny","moe","jack"] )
    assert_equal ["manny","moe","jack"], ad.from_store( ["manny","moe","jack"] )
  end

  should "delegate to the class for validation" do
    ad = Aggregate::AttributeHandler.has_many_factory("testme", "string", :size => 10)

    assert_equal_with_diff [], ad.validation_errors(["manny","moe","jack"])

    expected = ["is invalid"]
    assert_equal_with_diff expected, ad.validation_errors(["manny","moe","jack","this_is_too_long"])
  end

  should "collapse errors to the base class if specified" do
    ad = Aggregate::AttributeHandler.has_many_factory("testme", "string", :size => 10, :collapse_errors => true)

    assert_equal_with_diff [], ad.validation_errors(["manny","moe","jack"])
    expected = ["String is too long (maximum is 10 characters)"]
    assert_equal_with_diff expected, ad.validation_errors(["manny","moe","jack","this_is_too_long", "this is way too long too"])
  end

  should "convert the name to a string" do
    ad = Aggregate::AttributeHandler.has_many_factory(:testme, "string", :size => 10)
    assert_equal "testme", ad.name
  end


end
