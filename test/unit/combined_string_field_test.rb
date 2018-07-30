# frozen_string_literal: true

require_relative '../test_helper'

class Aggregate::CombinedStringFieldTest < ActiveSupport::TestCase

  module ActiveRecordStub
  end

  context "combined_string_fields" do
    setup do
      @parent_class = Class.new
      @parent_class.send(:attr_accessor, :storage_attribute, :method_calls)
      @parent_class.send(:define_method, "read_attribute") do |attribute_name|
        @method_calls ||= []
        @method_calls << ["read_attribute", attribute_name]
        @storage_attribute
      end
      @parent_class.send(:define_method, "write_attribute") do |attribute_name, value|
        @method_calls ||= []
        @method_calls << ["write_attribute", attribute_name, value]
        @storage_attribute = value
      end

      @class = Class.new(@parent_class)
      @class.extend ActiveRecordStub
      @class.extend Aggregate::CombinedStringField
      @class.combine_string_fields([:first, :second, :third, [:truthy, :boolean]], store_on: :storage_attribute)
      @instance = @class.new
    end

    context "write_attribute" do
      should "use defined accessor if attribute in list" do
        mock(@instance, "first=").with("123")
        @instance.write_attribute("first", "123")
      end
    end

    context "read_attribute" do
      should "use defined accessor if attribute in list" do
        mock(@instance).first { "123" }
        assert_equal "123", @instance.read_attribute("first")
      end
    end

    should "define accessors " do
      assert @instance.respond_to?("first")
      assert @instance.respond_to?("second")
      assert @instance.respond_to?("third")
      assert @instance.respond_to?("truthy")
      assert @instance.respond_to?("first=")
      assert @instance.respond_to?("second=")
      assert @instance.respond_to?("third=")
      assert @instance.respond_to?("truthy=")
    end

    should "allow assignment" do
      @instance.first   = "abc"
      @instance.second  = "def"
      @instance.third   = "ghi"
      @instance.truthy  = true

      assert_equal "abc", @instance.first
      assert_equal "def", @instance.second
      assert_equal "ghi", @instance.third
      assert_equal true, @instance.truthy

      assert_equal "abc\ndef\nghi\ntrue", @instance.storage_attribute

      @instance.truthy = false
      assert_equal "abc\ndef\nghi\nfalse", @instance.storage_attribute
    end

    should "convert types" do
      @instance.truthy = @instance
      assert_equal "\n\n\ntrue", @instance.storage_attribute
    end

    should "raise if an error if a newline is used in an input" do
      ex = assert_raises ArgumentError do
        @instance.first = "abc\n123"
      end
      assert ex.message =~ /Cannot store newlines in combined fields storing \"abc\\n123\" in first/
    end

    should "report if an attribute changed" do
      assert !@instance.first_changed?
      @instance.first = "abc"
      assert @instance.first_changed?
    end

    should "report empty for empty values" do
      @instance.second = "def"
      assert_equal "", @instance.first
    end

    should "allow assignment of nil" do
      @instance.second = nil
      assert_equal "", @instance.second
    end
  end
end
