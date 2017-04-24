require_relative '../test_helper'

class Aggregate::AggregateStoreTest < ActiveSupport::TestCase

  class OwnerStub
    attr_accessor :change_called
    def set_changed
      @change_called = true
    end
  end

  class ErrorsStub
    attr_accessor :messages
    def add(attr, message)
      (@messages ||= []) << [attr, message]
    end
  end

  context "aggregate_attribute" do
    setup do
      @store = Class.new {}
      @store.send(:include, Aggregate::AggregateStore)
      @store.aggregate_attribute(:name, :string)
    end

    should "define methods on the class when called" do
      assert_equal ["name"], @store.aggregated_attribute_handlers.map { |_, aa| aa.name }

      @instance = @store.new
      assert @instance.respond_to?(:name)
      assert @instance.respond_to?(:name=)
      assert @instance.respond_to?(:name_changed?)
      assert @instance.respond_to?(:build_name)
      assert @instance.respond_to?(:name_before_type_cast)
    end

    context "an instance" do
      setup do
        @instance = @store.new
        @store.send(:attr_accessor, :new_record, :errors)
        @store.send(:define_method, :aggregate_owner) { @aggregate_owner ||= OwnerStub.new }
        @store.send(:define_method, :decoded_aggregate_store) { { "name" => "abc" } }
        @store.send(:define_method, :new_record?) { @new_record }
        @store.send(:define_method, :run_callbacks) { |_foo| true }
      end

      should "respond to changed? apropriately when the instance is a active record object" do
        # change trigged by a active record attribute change

        passport = sample_passport
        passport.name = "blah"
        assert passport.changed?

        passport = Passport.find(passport.id)

        # change trigged by a aggregate attribute change
        passport.foreign_visits = [ForeignVisit.new(country: "Canada"), ForeignVisit.new(country: "Mexico")]
        assert passport.changed?

        passport = Passport.find(passport.id)

        # not mark changed if the aggregate value being assigned is same as before
        assert_equal [], passport.foreign_visits
        passport.foreign_visits = []
        assert !passport.changed?
      end

      should "respond to changed? appropriatetly when instance is not a active record object" do
        assert !@instance.changed?

        @instance.name = "blah"
        assert @instance.changed?
      end

      should "load from a store when constructed" do
        assert_equal "abc", @instance.name
      end

      should "allow the attribute to be set" do
        @instance.name = "godzilla"
        assert_equal "godzilla", @instance.name
      end

      should "allow the attribute to be built" do
        @instance.build_name("toodles")
        assert_equal "toodles", @instance.name
      end

      should "have explicit methods for getting and setting of attributes" do
        assert_equal "abc", @instance.get_aggregate_attribute("name")

        @instance.set_aggregate_attribute("name", "def")
        assert_equal "def", @instance.name
      end

      should "keep track of changes to the attribute" do
        assert !@instance.name_changed?
        assert !@instance.aggregate_owner.change_called
        assert_equal "abc", @instance.name_before_type_cast

        @instance.name = "godzilla"

        assert @instance.name_changed?
        assert_equal "godzilla", @instance.name_before_type_cast
        assert @instance.aggregate_owner.change_called
      end

      should "marshal the attributes in to_store" do
        expected = { "name" => "abc" }
        assert_equal expected, @instance.to_store
      end

      context "validate_aggregates" do
        setup do
          @instance.errors = ErrorsStub.new
        end

        should "validates aggregates if a new record" do
          @instance.new_record = true
          mock.instance_of(Aggregate::Attribute::String).validation_errors("abc") { ["had_error"] }
          @instance.validate_aggregates
          assert_equal [%w(name had_error)], @instance.errors.messages
        end

        should "validate aggregates if they force it" do
          mock.instance_of(Aggregate::Attribute::String).force_validation? { true }
          mock.instance_of(Aggregate::Attribute::String).validation_errors("abc") { ["had_error"] }
          @instance.validate_aggregates
          assert_equal [%w(name had_error)], @instance.errors.messages
        end

        should "validate aggregates if it changed" do
          @instance.name = "godzilla"
          mock.instance_of(Aggregate::Attribute::String).validation_errors("godzilla") { ["had_error"] }
          @instance.validate_aggregates
          assert_equal [%w(name had_error)], @instance.errors.messages
        end

        should "validate aggregates if was accessed" do
          @instance.name
          mock.instance_of(Aggregate::Attribute::String).validation_errors("abc") { ["had_error"] }
          @instance.validate_aggregates
          assert_equal [%w(name had_error)], @instance.errors.messages
        end

        should "not validate an aggregate otherwise" do
          dont_allow.instance_of(Aggregate::Attribute::String).validation_errors("abc")
          @instance.validate_aggregates
        end
      end

      context "has_many aggregates" do
        setup do
          @store = Class.new {}
          @store.send(:include, Aggregate::AggregateStore)
          @store.aggregate_has_many(:names, :string)
        end

        should "default to an empty list" do
          @instance = @store.new
          @store.send(:define_method, :aggregate_owner) { @aggregate_owner ||= OwnerStub.new }
          @store.send(:define_method, :decoded_aggregate_store) { { "names" => nil } }
          @store.send(:define_method, :new_record?) { @new_record }
          @store.send(:define_method, :run_callbacks) { |_foo| true }

          assert_equal [], @instance.names
        end

        should "allow assignment" do
          @instance = @store.new
          @store.send(:define_method, :aggregate_owner) { @aggregate_owner ||= OwnerStub.new }
          @store.send(:define_method, :decoded_aggregate_store) { { "names" => nil } }
          @store.send(:define_method, :new_record?) { @new_record }
          @store.send(:define_method, :run_callbacks) { |_foo| true }

          @instance.names = %w(manny moe jack)
          assert_equal %w(manny moe jack), @instance.names
        end

        should "allow lists to be saved to disk" do
          @store.send(:define_method, :aggregate_owner) { @aggregate_owner ||= OwnerStub.new }
          @store.send(:define_method, :decoded_aggregate_store) { { "names" => nil } }
          @store.send(:define_method, :new_record?) { @new_record }
          @store.send(:define_method, :run_callbacks) { |_foo| true }
          @instance = @store.new

          @instance.names = %w(manny moe jack)
          assert_equal %w(manny moe jack), @instance.names

          expected = { "names" => %w(manny moe jack) }

          assert_equal expected, @instance.to_store
        end

        should "allow lists to be loaded from to disk" do
          @store.send(:define_method, :aggregate_owner) { @aggregate_owner ||= OwnerStub.new }
          @store.send(:define_method, :decoded_aggregate_store) { { "names" => %w(manny moe jack) } }
          @store.send(:define_method, :new_record?) { @new_record }
          @store.send(:define_method, :run_callbacks) { |_foo| true }
          @instance = @store.new

          assert_equal %w(manny moe jack), @instance.names
        end

        context "lists of aggregates" do
          setup do
            @agg = Class.new(Aggregate::Base) {}
            @agg.attribute(:name, :string)
            @agg.attribute(:address, :string)
            @agg.attribute(:zip, :integer)
            silence_warnings { ::MyTestClass = @agg }
            @store.aggregate_has_many(:things, MyTestClass.name)

            @store.send(:attr_accessor, :new_record, :errors)
            @store.send(:define_method, :aggregate_owner) { @aggregate_owner ||= OwnerStub.new }
            @store.send(:define_method, :decoded_aggregate_store) { { "things" => [{ "name" => "Moe" }, { "name" => "Larry" }, { "name" => "Curly" }] } }
            @store.send(:define_method, :new_record?) { @new_record }
            @store.send(:define_method, :run_callbacks) { |_foo| true }

            @instance = @store.new
          end

          should "set the owner on the aggregate owner when loaded" do
            assert_equal 3, @instance.things.size
            @instance.things.each do |saved_thing|
              assert_equal @instance, saved_thing.aggregate_owner
            end
          end

          should "set the owner on the aggregate owner when assigned" do
            @instance.things = [MyTestClass.new(name: "Moe"), MyTestClass.new(name: "Larry"), MyTestClass.new(name: "Curly")]

            @instance.things.each do |saved_thing|
              assert_equal @instance, saved_thing.aggregate_owner
            end
          end
        end
      end

      context "belongs_to aggregates" do
        setup do
          @store = Class.new {}
          @store.send(:include, Aggregate::AggregateStore)
          @store.aggregate_belongs_to(:passport, class_name: "Passport")
          @store.send(:define_method, :aggregate_owner) { @aggregate_owner ||= OwnerStub.new }
          @store.send(:define_method, :decoded_aggregate_store) { { "names" => nil } }
          @store.send(:define_method, :run_callbacks) { |_foo| true }
          @store.send(:define_method, :new_record?) { @new_record }
          @passport = sample_passport
          @instance = @store.new
        end

        should "allow assignment by instance" do
          @instance.passport = @passport

          expected = { "passport_id" => @passport.id }
          assert_equal expected, @instance.to_store

          assert_equal @passport, @instance.passport
          assert_equal @passport.id, @instance.passport_id
        end

        should "allow assignment by id" do
          @instance.passport_id = @passport.id

          expected = { "passport_id" => @passport.id }
          assert_equal expected, @instance.to_store

          assert_equal @passport, @instance.passport
          assert_equal @passport.id, @instance.passport_id
        end
      end

      context "schema versioning" do
        should "allow a schema version to be defined." do
          @store = Class.new {}
          [:save, :save!, :create_or_update, :create, :update, :destroy, :valid?].each do |method|
            @store.send(:define_method, method) { raise "call #{method} on containing class" }
          end

          @store.send(:include, Aggregate::AggregateStore)
          @store.send(:include, ActiveRecord::Callbacks)
          @store.send(:define_callbacks, :before_validation, :after_aggregate_load, :aggregate_load_check_schema)
          @store.send(:define_method, :aggregate_owner) { @aggregate_owner ||= OwnerStub.new }
          @store.send(:define_method, :decoded_aggregate_store) { { "names" => nil } }
          @store.send(:define_method, :run_callbacks) { |_foo| true }
          @store.send(:define_method, :new_record?) { @new_record }
          @store.send(:define_method, :fixup_schema) { |_current_version| @fixed_from_current_version }
          @store.send(:define_method, :run_callbacks) { |_foo| true }
          @store.aggregate_schema_version("1.0", :fixup_schema)

          @instance = @store.new
        end
      end

      should "clear assignments after reload" do
          @base_class = Class.new {}
          @base_class.send(:define_method, :reload) { @reload_called = true}

          @store = Class.new(@base_class) {}
          @store.send(:include, Aggregate::AggregateStore)
          @store.aggregate_belongs_to(:passport, class_name: "Passport")
          @store.send(:define_method, :aggregate_owner) { @aggregate_owner ||= OwnerStub.new }
          @store.send(:define_method, :run_callbacks) { |_foo| true }
          @store.send(:define_method, :new_record?) { @new_record }
          @store.send(:attr_accessor, :decoded_aggregate_store )
          @passport = sample_passport
          @instance = @store.new

          @instance.decoded_aggregate_store = {}
          @instance.passport = @passport

          expected = { "passport_id" => @passport.id }
          assert_equal expected, @instance.to_store

          @instance.reload
          expected = {}
          assert_equal expected, @instance.to_store
          assert_equal true, @instance.instance_variable_get("@reload_called")
      end
    end
  end
end
