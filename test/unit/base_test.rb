require_relative '../test_helper'

class Aggregate::BaseTest < ActiveSupport::TestCase

  context "Aggregate classes" do
    setup do
      @agg = Class.new(Aggregate::Base) {}
      @agg.attribute(:name, :string)
      @agg.attribute(:address, :string, default: "no address")
      @agg.attribute(:zip, :integer)
      silence_warnings { MyTestClass = @agg }

      @decoded_aggregate_store = { "name" => "Bob", "address" => "1812 clearview", "zip" => 93_101 }
    end

    should "raise if an unsupported method is called" do
      @instance = @agg.new
      assert_raise(RuntimeError) { @instance.save }
      assert_raise(RuntimeError) { @instance.save! }
      assert_raise(RuntimeError) { @instance.send(:create_or_update) }
      assert_raise(RuntimeError) { @instance.send(:create) }
      assert_raise(RuntimeError) { @instance.send(:update) }
      assert_raise(RuntimeError) { @instance.send(:destroy) }
    end

    should "allow instances to be initialized from the constructor" do
      @instance = @agg.new(name: "Bob", address: "1812 clearview", zip: 93_101)
      assert_equal "Bob", @instance.name
      assert_equal "1812 clearview", @instance.address
      assert_equal 93_101, @instance.zip

      assert @instance.new_record?
    end

    should "raise if invalid attribute specified in the constructor" do
      assert_raise(NoMethodError) { @agg.new(name: "Bob", address: "1812 clearview", invalid: 93_101) }
    end

    should "allow an instance to be initialized from a store" do
      @instance = @agg.from_store(@decoded_aggregate_store)
      assert_equal "Bob", @instance.name
      assert_equal "1812 clearview", @instance.address
      assert_equal 93_101, @instance.zip
      assert !@instance.new_record?
    end

    context "to_json" do
      should "generate a string with all attributes" do
        @instance = @agg.new(name: "Bob", address: "1812 clearview", zip: 93_101)
        expected_json_string = ActiveSupport::JSON.encode(@decoded_aggregate_store)
        assert_equal expected_json_string, @instance.to_json
      end

      should "generate a string with all the attributes after just being built from json" do
        @instance = @agg.new(name: "Bob", address: "1812 clearview", zip: 93_101)
        test_instance = @agg.from_json(@instance.to_json)

        expected_json_string = ActiveSupport::JSON.encode(@decoded_aggregate_store)
        assert_equal expected_json_string, test_instance.to_json
      end

      should "generate a string with all the attributes after just being built from json and is in an array" do
        @instance = @agg.new(name: "Bob", address: "1812 clearview", zip: 93_101)
        test_instance = [@agg.from_json(@instance.to_json)]

        expected_json_string = ActiveSupport::JSON.encode([@decoded_aggregate_store])
        assert_equal expected_json_string, test_instance.to_json
      end
    end

    context "from_json" do
      should "create an instance from a json with valid keys" do
        aggregate_data = ActiveSupport::JSON.encode({ "name" => "Bob", "address" => "1812 clearview", "zip" => 93_101 })
        @instance = @agg.from_json(aggregate_data)

        assert_equal "Bob", @instance.name
        assert_equal "1812 clearview", @instance.address
        assert_equal 93_101, @instance.zip
        assert @instance.new_record?
      end

      should "create an instance from a json with invalid keys" do
        hash = ActiveSupport::JSON.encode({ "invalid_key1" => "Bob", "invalid_key2" => "1812 clearview" })
        @instance = @agg.from_json(hash)

        assert_equal nil, @instance.name
        assert_equal nil, @instance.address
        assert_equal nil, @instance.zip
        assert @instance.new_record?
      end

      should "create an instance from a json with partial valid keys" do
        hash = ActiveSupport::JSON.encode({ "name" => "Bob", "invalid_key2" => "1812 clearview", "zip" => 93_101 })
        @instance = @agg.from_json(hash)

        assert_equal "Bob", @instance.name
        assert_equal nil, @instance.address
        assert_equal 93_101, @instance.zip
        assert @instance.new_record?
      end

      should "create an instance with default values for an empty json" do
        hash = ActiveSupport::JSON.encode({})
        @instance = @agg.from_json(hash)

        assert_equal nil, @instance.name
        assert_equal 'no address', @instance.address
        assert_equal nil, @instance.zip
        assert @instance.new_record?
      end

      should "create an instance with default values if no json provided" do
        hash = ActiveSupport::JSON.encode(nil)
        @instance = @agg.from_json(hash)

        assert_equal nil, @instance.name
        assert_equal 'no address', @instance.address
        assert_equal nil, @instance.zip
        assert @instance.new_record?
      end
    end

    should "provide support methods needed by validatable and by callbacks" do
      assert_equal [@agg], @agg.self_and_descendants_from_active_record
      assert_equal "Aggregate::basetest::mytestclass", @agg.human_name
      assert_equal "Cheese burger", @agg.human_attribute_name(:cheese_burger)
      assert_equal nil, @agg.new.respond_to_without_attributes?("could", "be", "anything")
    end

    should "provide comparable methods for instances" do
      @first  = @agg.new(name: "Bob", address: "1812 clearview", zip: 93_101)
      @same   = @agg.new(name: "Bob", address: "1812 clearview", zip: 93_101)
      @second = @agg.new(name: "Bob", address: "1812 clearview", zip: 93_102)

      assert @first == @same
      assert @first != @second
      assert @first < @second
    end

    should "support comparison for nested instances" do
      @outer_agg = Class.new(Aggregate::Base) {}
      @outer_agg.attribute(:address1, @agg.name)
      @outer_agg.attribute(:address2, @agg.name)
      @outer_agg.attribute(:type, "enum")
      @outer_agg.attribute(:istrue, "boolean")

      @first = @outer_agg.new(
        type: :tiger,
        istrue: false,
        address1: @agg.new(name: "Bob", address: "1812 clearview", zip: 93_101),
        address2: @agg.new(name: "Murphy", address: "1414 mountain", zip: 93_103)
      )

      @second = @outer_agg.new(
        type: :tiger,
        istrue: false,
        address1: @agg.new(name: "Bob", address: "1812 clearview", zip: 93_101),
        address2: @agg.new(name: "Murphy", address: "1414 mountain", zip: 93_103)
      )

      assert @first == @second
      @second.address2.zip = 93_102
      assert @first != @second
      assert @first > @second

      @second.address2.zip = 93_103
      assert @first == @second

      @first.type = nil
      assert @first != @second
      assert @first > @second

      @second.type = nil
      assert @first == @second
    end

    context "has_many associations" do
      should "be able to declare has many associations" do
        @outer_agg = Class.new(Aggregate::Base) {}
        @outer_agg.has_many(:addresses, @agg.name)
      end

      should "be able to declare belongs to associations" do
        @outer_agg = Class.new(Aggregate::Base) {}
        @outer_agg.belongs_to(:network)
      end
    end

    context "callbacks" do
      setup do
        @agg = Class.new(Aggregate::Base) {}
        @agg.attribute(:name, :string)
        @agg.attribute(:address, :string)
        @agg.attribute(:zip, :integer)
        @agg.send(:set_callback, :aggregate_load, :after, :aggregate_loaded)
        @agg.send(:define_method, :aggregate_loaded) { puts; puts "Aggregate Loaded" }
      end

      should "call the aggregate loaded method when the object is loaded" do
        mock.instance_of(@agg).aggregate_loaded
        @instance = @agg.from_store(name: "loaded")
        @instance.name
      end
    end

    context "secret keys" do
      setup do
        Aggregate.reset
      end
      should "return nil when keys_list is nil" do
        assert_equal [], Aggregate::Base.secret_keys_from_config
        Aggregate.reset
      end

      should "return nil when keys_list is something other than a string or hash" do
        Aggregate.configure do |config|
          config.keys_list = Object.new
        end
        assert_equal [], Aggregate::Base.secret_keys_from_config
        Aggregate.reset
      end

      should "return a array when keys_list is a string" do
        Aggregate.configure do |config|
          config.keys_list = "AES-this_is_a_test"
        end

        assert Aggregate.configuration.keys_list.is_a?(String)
        assert Aggregate::Base.secret_keys_from_config.is_a?(Array)
        Aggregate.reset
      end

      should "return a array when keys_list is an array" do
        Aggregate.configure do |config|
          config.keys_list = ["AES-this_is_a_test", "AES-this_is_a_random_test"]
        end

        assert Aggregate.configuration.keys_list.is_a?(Array)
        assert Aggregate::Base.secret_keys_from_config.is_a?(Array)
        Aggregate.reset
      end
    end
  end
end
