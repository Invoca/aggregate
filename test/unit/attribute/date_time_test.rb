require_relative '../../test_helper'

class Aggregate::Attribute::DateTimeTest < ActiveSupport::TestCase

  should "handle datetime" do
    overrides_time(Time.zone.local(2008, 3, 10)) do
      ad = Aggregate::AttributeHandler.factory("testme", :datetime, {})
      assert_equal "04/18/12   5:50 PM", ad.from_value("2012/04/18 17:50:08 -0700").to_s
      assert_equal "03/10/08  12:00 AM", ad.from_value(Time.now).to_s

      assert_equal "Mon, 10 Mar 2008 07:00:00 -0000", ad.to_store(Time.now)
      assert_equal "03/10/08  12:00 AM", ad.from_store("Mon, 10 Mar 2008 07:00:00 -0000").to_s

      # Load into users timezone, store the same regardless of timezone
      overrides_time_zone "Eastern Time (US & Canada)" do
        assert_equal "03/10/08   3:00 AM", ad.from_store("Mon, 10 Mar 2008 07:00:00 -0000").to_s
        assert_equal "Mon, 10 Mar 2008 07:00:00 -0000", ad.to_store(Time.now)
      end
      assert_equal ActiveSupport::TimeWithZone, ad.new(Time.now).class
    end
  end

end
