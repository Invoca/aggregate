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

  context "with aggregate_db_storage_type" do
    context ":elasticsearch" do
      should "handle parsing and storing datetime with second precision" do
        ad   = Aggregate::AttributeHandler.factory("testme", :datetime, aggregate_db_storage_type: :elasticsearch)
        time = Time.at(1_544_732_833.1234).in_time_zone("Pacific Time (US & Canada)")

        assert_equal "12/13/18   8:27 PM", ad.from_value(time.iso8601).utc.to_s
        assert_equal "2018-12-13T20:27:13Z", ad.to_store(time)
      end
    end
  end

  context "with :format option" do
    should "handle parsing and storing datetime based on the given format" do
      ad   = Aggregate::AttributeHandler.factory("testme", :datetime, format: :short)
      time = Time.at(1_544_732_833).in_time_zone("Pacific Time (US & Canada)")

      assert_equal "12/13/18   8:27 PM", ad.from_value(time.iso8601).utc.to_s
      assert_equal "13 Dec 20:27", ad.to_store(time)
    end
  end

  context "with :formatter option" do
    should "format the datetime by calling the formatter method" do
      ad   = Aggregate::AttributeHandler.factory("testme", :datetime, formatter: formatter_proc)
      time = Time.at(1_544_732_833).in_time_zone("Pacific Time (US & Canada)")

      assert_equal "12/13/18   8:27 PM", ad.from_value(time.iso8601).utc.to_s
      assert_equal 1_544_732_833, ad.to_store(time)
    end
  end

  context "with :format option and :aggregate_db_storage_type options" do
    should "prefer :format over :aggregate_db_storage_type" do
      ad   = Aggregate::AttributeHandler.factory("testme", :datetime, format: :short, aggregate_db_storage_type: :elasticsearch)
      time = Time.at(1_544_732_833).in_time_zone("Pacific Time (US & Canada)")

      assert_equal "12/13/18   8:27 PM", ad.from_value(time.iso8601).utc.to_s
      assert_equal "13 Dec 20:27", ad.to_store(time)
    end
  end

  context "with :format option and :formatter options" do
    should "prefer :format over :formatter" do
      ad   = Aggregate::AttributeHandler.factory("testme", :datetime, format: :short, formatter: formatter_proc)
      time = Time.at(1_544_732_833).in_time_zone("Pacific Time (US & Canada)")

      assert_equal "12/13/18   8:27 PM", ad.from_value(time.iso8601).utc.to_s
      assert_equal "13 Dec 20:27", ad.to_store(time)
    end
  end

  context "with :formatter and :aggregate_db_storage_type options" do
    should "prefer :formatter over :aggregate_db_storage_type" do
      ad   = Aggregate::AttributeHandler.factory("testme", :datetime, aggregate_db_storage_type: :elasticsearch, formatter: formatter_proc)
      time = Time.at(1_544_732_833).in_time_zone("Pacific Time (US & Canada)")

      assert_equal "12/13/18   8:27 PM", ad.from_value(time.iso8601).utc.to_s
      assert_equal 1_544_732_833, ad.to_store(time)
    end
  end

  should "Load into users timezone, store the same regardless of timezone" do
    user_time = Time.zone.local(2008, 3, 10).in_time_zone("Eastern Time (US & Canada)")
    begin
      old_time_zone = Time.zone
      Time.zone     = "Eastern Time (US & Canada)"
      ad            = Aggregate::AttributeHandler.factory("testme", :datetime, {})
      assert_equal "03/10/08   3:00 AM", ad.from_store("Mon, 10 Mar 2008 07:00:00 -0000").to_s
      assert_equal "Mon, 10 Mar 2008 07:00:00 -0000", ad.to_store(user_time)
    ensure
      Time.zone = old_time_zone
    end
  end

  def formatter_proc
    ->(datetime) { datetime.to_i }
  end
end
