require_relative '../../test_helper'

class Aggregate::Attribute::DateTimeTest < ActiveSupport::TestCase

  should "handle datetime" do
    ad = Aggregate::AttributeHandler.factory("testme", :datetime, {})
    stub(Time).now { Time.zone.local(2008, 3, 10) }
    assert_equal "04/18/12   5:50 PM", ad.from_value("2012/04/18 17:50:08 -0700").to_s
    assert_equal "03/10/08  12:00 AM", ad.from_value(Time.now).to_s

    assert_equal "Mon, 10 Mar 2008 07:00:00 -0000", ad.to_store(Time.now)
    assert_equal "03/10/08  12:00 AM", ad.from_store("Mon, 10 Mar 2008 07:00:00 -0000").to_s

    assert_equal ActiveSupport::TimeWithZone, ad.new(Time.now).class
  end

  should "Load into users timezone, store the same regardless of timezone" do
    user_time = Time.zone.local(2008, 3, 10).in_time_zone("Eastern Time (US & Canada)")
    begin
      old_time_zone, Time.zone = Time.zone, "Eastern Time (US & Canada)"
      ad = Aggregate::AttributeHandler.factory("testme", :datetime, {})
      assert_equal "03/10/08   3:00 AM", ad.from_store("Mon, 10 Mar 2008 07:00:00 -0000").to_s
      assert_equal "Mon, 10 Mar 2008 07:00:00 -0000", ad.to_store(user_time)
    ensure
      Time.zone = old_time_zone
    end
  end
end
