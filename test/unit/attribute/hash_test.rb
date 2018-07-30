# frozen_string_literal: true

require_relative '../../test_helper'

class Aggregate::Attribute::HashTest < ActiveSupport::TestCase

  class SampleObject
    def to_hash
      { definitely: 'works' }
    end
  end

  context "Hash attribute" do
    setup do
      @ad = Aggregate::AttributeHandler.factory("testme", :hash, {})
    end

    should "handle hash" do
      assert_kind_of Hash, @ad.new(key: 'value')
      assert_kind_of Hash, @ad.new({ key: 'value' }.to_json)
    end

    context "#load" do
      should "decode json strings and return a hash" do
        assert_equal({}, @ad.load("{}"))
      end

      should "keep hash values" do
        assert_equal({}, @ad.load({}))
      end

      should "handle nil value" do
        assert_equal({}, @ad.load(nil))
      end

      should "handle empty string" do
        assert_equal({}, @ad.load(""))
      end

      should "handle objects that respond to to_hash" do
        assert_equal({ definitely: 'works' }, @ad.load(SampleObject.new))
      end
    end

    context "#assign" do
      should "decode json strings and return a hash" do
        assert_equal({}, @ad.assign("{}"))
      end

      should "keep hash values" do
        assert_equal({}, @ad.assign({}))
      end

      should "handle nil value" do
        assert_equal({}, @ad.assign(nil))
      end

      should "handle empty string" do
        assert_equal({}, @ad.assign(""))
      end

      should "handle objects that respond to to_hash" do
        assert_equal({ definitely: 'works' }, @ad.assign(SampleObject.new))
      end
    end

    context "#store" do
      should "encode hash values as json" do
        assert_equal "{}", @ad.store({})
      end

      should "keep json strings" do
        assert_equal "{}", @ad.store("{}")
      end
    end

    context "#from_value" do
      should "decode json strings and return a hash" do
        assert_equal({}, @ad.from_value("{}"))
      end

      should "keep hash values" do
        assert_equal({}, @ad.from_value({}))
      end

      should "handle nil value" do
        assert_equal({}, @ad.from_value(nil))
      end

      should "handle empty string" do
        assert_equal({}, @ad.from_value(""))
      end

      should "handle objects that respond to to_hash" do
        assert_equal({ definitely: 'works' }, @ad.from_value(SampleObject.new))
      end
    end

    context "#from_store" do
      should "decode json strings and return a hash" do
        assert_equal({}, @ad.from_store("{}"))
      end

      should "handle nil value" do
        assert_equal({}, @ad.from_store(nil))
      end
    end

    context "#to_store" do
      should "encode hash values as json" do
        assert_equal "{}", @ad.to_store({})
      end

      should "keep json strings" do
        assert_equal "{}", @ad.to_store("{}")
      end

      should "return nil values as empty json string hash" do
        assert_equal "{}", @ad.to_store(nil)
      end
    end
  end

end
