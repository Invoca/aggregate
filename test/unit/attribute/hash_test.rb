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
      context "store_hash_as_json defaulted as true" do
        setup do
          assert_equal({}, @ad.options)
        end

        should "encode hash values as json" do
          assert_equal "{}", @ad.store({})
        end

        should "keep json strings" do
          assert_equal "{}", @ad.store("{}")
        end
      end

      context "store_hash_as_json as false" do
        setup do
          @attribute_handler = Aggregate::AttributeHandler.factory("testme", :hash, store_hash_as_json: false)
        end

        should "encode hash values as hashes" do
          assert_equal({ a: 1 }, @attribute_handler.store(a: 1))
        end

        should "expand json strings as hashes" do
          assert_equal({ "a" => 1 }, @attribute_handler.store("{\"a\":1}"))
        end

        should "set default value as empty hash" do
          assert_equal({}, @attribute_handler.store(nil))
        end

        should "set empty string as default value" do
          assert_equal({}, @attribute_handler.store(""))
        end
      end

      context "aggregate_db_storage_type option as :elasticsearch" do
        setup do
          @attribute_handler = Aggregate::AttributeHandler.factory("testme", :hash, aggregate_db_storage_type: :elasticsearch)
        end

        should "encode hash values as hashes" do
          assert_equal({ a: 1 }, @attribute_handler.store(a: 1))
        end

        should "expand json strings as hashes" do
          assert_equal({ "a" => 1 }, @attribute_handler.store("{\"a\":1}"))
        end

        should "set default value as empty hash" do
          assert_equal({}, @attribute_handler.store(nil))
        end

        should "set empty string as default value" do
          assert_equal({}, @attribute_handler.store(""))
        end
      end

      context "supplying both :store_hash_as_json and :aggregate_db_storage_type options" do
        should "prefer store_hash_as_json over aggregate_db_storage_type" do
          attr_handler = Aggregate::AttributeHandler.factory("testme", :hash, store_hash_as_json: true, aggregate_db_storage_type: :elasticsearch)
          assert_equal "{\"a\":1}", attr_handler.store(a: 1)
        end
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

    context "default handling" do
      setup do
        @store = Class.new(Aggregate::Base) do
          aggregate_attribute(:inventory, :hash)
        end
      end

      should "not share the default value instance" do
        first_store = @store.new
        second_store = @store.new
        first_store.inventory["eggs"] = 100

        assert_equal({}, second_store.inventory)
      end
    end
  end

end
