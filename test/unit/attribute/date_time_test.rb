# frozen_string_literal: true

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

  should "handle parsing and storing datetime based on aggregate_db_storage_type option being :elasticsearch" do
    ad   = Aggregate::AttributeHandler.factory("testme", :datetime, aggregate_db_storage_type: :elasticsearch)
    time = Time.at(1_544_732_833).in_time_zone("Pacific Time (US & Canada)")

    assert_equal "12/13/18   8:27 PM", ad.from_value(time.iso8601).utc.to_s
    assert_equal "2018-12-13T20:27:13.000Z", ad.to_store(time)
  end

  should "handle parsing and storing datetime based on format option" do
    ad   = Aggregate::AttributeHandler.factory("testme", :datetime, format: :short)
    time = Time.at(1_544_732_833).in_time_zone("Pacific Time (US & Canada)")

    assert_equal "12/13/18   8:27 PM", ad.from_value(time.iso8601).utc.to_s
    assert_equal "13 Dec 20:27", ad.to_store(time)
  end

  should "prefer :format over :aggregate_db_storage_type option" do
    ad   = Aggregate::AttributeHandler.factory("testme", :datetime, format: :short, aggregate_db_storage_type: :elasticsearch)
    time = Time.at(1_544_732_833).in_time_zone("Pacific Time (US & Canada)")

    assert_equal "12/13/18   8:27 PM", ad.from_value(time.iso8601).utc.to_s
    assert_equal "13 Dec 20:27", ad.to_store(time)
  end

  should "Load into users timezone, store the same regardless of timezone" do
    user_time = Time.zone.local(2008, 3, 10).in_time_zone("Eastern Time (US & Canada)")
    begin
      old_time_zone = Time.zone
      Time.zone = "Eastern Time (US & Canada)"
      ad = Aggregate::AttributeHandler.factory("testme", :datetime, {})
      assert_equal "03/10/08   3:00 AM", ad.from_store("Mon, 10 Mar 2008 07:00:00 -0000").to_s
      assert_equal "Mon, 10 Mar 2008 07:00:00 -0000", ad.to_store(user_time)
    ensure
      Time.zone = old_time_zone
    end
  end
end
