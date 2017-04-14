require 'test_helper'

class AggregateTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Aggregate
  end

  context "configure" do
    should "configure an encryption key" do
      Aggregate.configure do |config|
        config.encryption_key = "AES-this_is_a_test"
      end

      aggregate = Aggregate::Base.new
      assert_equal "AES-this_is_a_test", aggregate.encryption_key
    end
  end
end
