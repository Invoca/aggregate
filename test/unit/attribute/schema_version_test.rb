# frozen_string_literal: true

require_relative '../../test_helper'

class Aggregate::Attribute::SchemaVersionTest < ActiveSupport::TestCase

  should "handle strings" do
    ad = Aggregate::Attribute::SchemaVersion.new("1.0", :fixup)
    assert_equal "0.9", ad.from_value("0.9")
    assert_equal "0.9", ad.from_store("0.9")
    assert_equal "1.0", ad.to_store(nil)

    assert_equal "1.01", ad.from_value(1.01)
  end

end
