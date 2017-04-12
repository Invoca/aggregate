require 'test_helper'

class AggregateTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Aggregate
  end

  context "configure" do
    should "configure an encryption key" do
      Aggregate.configure do |config|
        config.encryption_key = "AES-this_is_a_test"
        config.iv = "This_is_also_bogus"
      end

      aggregate = Aggregate::Base.new
      assert_equal "AES-this_is_a_test", aggregate.encryption_key
      assert_equal "This_is_also_bogus", aggregate.iv
    end
  end
end
