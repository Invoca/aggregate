require 'test_helper'

class AggregateTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Aggregate
  end

  context "configure" do
    setup do
      Aggregate.configure do |config|
        config.keys_list = "AES-this_is_a_test"
      end
    end

    should "configure an encryption key" do
      assert_equal "AES-this_is_a_test", Aggregate.configuration.keys_list
    end

    should "reset configuration when called" do
      assert_equal "AES-this_is_a_test", Aggregate.configuration.keys_list

      Aggregate.reset

      assert_nil Aggregate.configuration.keys_list
    end

    should "raise when keys_list is something other than a string or hash" do
      assert_raise(Aggregate::ConfigurationError, /keys_list should be nil, String, or an Array/) do
        Aggregate.configure do |config|
          config.keys_list = Object.new
        end
      end
    end
  end
end
