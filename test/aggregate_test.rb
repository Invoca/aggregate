require 'test_helper'

class AggregateTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Aggregate
  end
end
