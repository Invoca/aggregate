# frozen_string_literal: true

require_relative '../test_helper'
require 'rails_upgrade_helpers/version'
require 'test_after_commit' if Rails::VERSION::MAJOR === 4

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

  def elasticsearch_store
    @elasticsearch_store ||=
      begin
        store = Class.new
        store.send(:include, Aggregate::AggregateStore)
        store.define_singleton_method(:aggregate_db_storage_type) { :elasticsearch }
        store
      end
  end

  context "aggregate_attribute" do
    setup do
      @store = Class.new
      @store.send(:include, Aggregate::AggregateStore)
      @store.aggregate_attribute(:name, :string)
    end

    should "pass aggregate_db_storage_type option to all attribute handlers if aggregate_db_storage_type is not nil" do
      elasticsearch_store.aggregate_attribute(:name, :string)
      elasticsearch_store.aggregate_attribute(:number, :integer)

      assert_equal [{ aggregate_db_storage_type: :elasticsearch }], elasticsearch_store.aggregated_attribute_handlers.values.map(&:options).uniq
    end

    should "define methods on the class when called" do
      assert_equal(["name"], @store.aggregated_attribute_handlers.map { |_, aa| aa.name })

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

      context "when an aggregate field is changed from and back to its initial value" do
        context "and owner is an Active Record object" do
          context "and there were no other aggregate field changes" do
            setup do
              @passport = sample_passport
              refute @passport.changed?
              original_foreign_visits = @passport.foreign_visits
              @passport.foreign_visits = [ForeignVisit.new(country: "Canada"), ForeignVisit.new(country: "Mexico")]
              assert @passport.changed?
              @passport.foreign_visits = original_foreign_visits
            end

            should "be falsy" do
              refute @passport.changed?
            end
          end

          context "and there were other aggregate field changes" do
            setup do
              @passport = sample_passport
              refute @passport.changed?
              original_foreign_visits = @passport.foreign_visits
              @passport.city = "Emond's Field"
              @passport.foreign_visits = [ForeignVisit.new(country: "Malkier"), ForeignVisit.new(country: "Cairhien")]
              assert @passport.changed?
              @passport.foreign_visits = original_foreign_visits
            end

            should "be truthy" do
              assert @passport.changed?
            end
          end
        end

        context "and owner is not an Active Record object" do
          setup do
            refute @instance.changed?
          end

          context "and there were no other aggregate field changes" do
            setup do
              original_name = @instance.name
              @instance.name = "Nynaeve"
              assert @instance.changed?
              @instance.name = original_name
            end

            should "be falsy" do
              refute @instance.changed?
            end
          end

          context "and there were other aggregate field changes" do
            setup do
              @store.aggregate_attribute(:age, :string)

              @instance = @store.new
              @instance.age = 20
              original_name = @instance.name
              @instance.name = "Nynaeve"
              assert @instance.changed?
              @instance.name = original_name
            end

            should "be truthy" do
              assert @instance.changed?
            end
          end
        end
      end

      context "for object with aggregate_has_many attribute" do
        setup do
          @passport = sample_passport
          @passport.update_attributes!(foreign_visits: [ForeignVisit.new(country: "Cairhien")])
        end

        context "and one of the aggregate_has_many individual instances has changed" do
          setup do
            @passport.foreign_visits.first.country = "Caemlyn"
          end

          should "correctly mark the attribute as changed" do
            # TODO: uncomment this when we address this bug
            # assert @passport.changed?, "passport not changed"
            assert @passport.foreign_visits_changed?, "foreign visits not changed"
          end
        end
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

      context "#aggregate_attribute_changes" do
        setup do
          @store.aggregate_attribute(:age, :integer)
          @store.aggregate_attribute(:unchanged_value, :string)
          @instance = @store.new
        end

        should "return rails like changes for aggregates" do
          @instance.name = "The Count"
          @instance.age = 999

          expected_changes = {
            "age" => [nil, 999],
            "name" => ["abc", "The Count"]
          }
          assert_equal expected_changes, @instance.aggregate_attribute_changes
        end

        should "be empty hash if there are no changes" do
          assert_equal({}, @instance.aggregate_attribute_changes)
        end

        context "when field changes to and from initial value" do
          setup do
            original_value = @instance.name
            @instance.name = "Perrin"
            @instance.name = original_value
          end

          should "not include the field" do
            assert_equal({}, @instance.aggregate_attribute_changes)
          end
        end
      end

      context "validate_aggregates" do
        setup do
          @instance.errors = ErrorsStub.new
        end

        should "validates aggregates if a new record" do
          @instance.new_record = true
          mock.instance_of(Aggregate::Attribute::String).validation_errors("abc") { ["had_error"] }
          @instance.validate_aggregates
          assert_equal [['name', 'had_error']], @instance.errors.messages
        end

        should "validate aggregates if they force it" do
          mock.instance_of(Aggregate::Attribute::String).force_validation? { true }
          mock.instance_of(Aggregate::Attribute::String).validation_errors("abc") { ["had_error"] }
          @instance.validate_aggregates
          assert_equal [['name', 'had_error']], @instance.errors.messages
        end

        should "validate aggregates if it changed" do
          @instance.name = "godzilla"
          mock.instance_of(Aggregate::Attribute::String).validation_errors("godzilla") { ["had_error"] }
          @instance.validate_aggregates
          assert_equal [['name', 'had_error']], @instance.errors.messages
        end

        should "validate aggregates if was accessed" do
          @instance.name
          mock.instance_of(Aggregate::Attribute::String).validation_errors("abc") { ["had_error"] }
          @instance.validate_aggregates
          assert_equal [['name', 'had_error']], @instance.errors.messages
        end

        should "not validate an aggregate otherwise" do
          dont_allow.instance_of(Aggregate::Attribute::String).validation_errors("abc")
          @instance.validate_aggregates
        end
      end

      context "has_many aggregates" do
        setup do
          @store = Class.new
          @store.send(:include, Aggregate::AggregateStore)
          @store.aggregate_has_many(:names, :string)
        end

        should "pass aggregate_db_storage_type option to element_helper in list attribute handler if aggregate_db_storage_type is not nil" do
          elasticsearch_store.aggregate_has_many(:names, :string)
          assert_equal({ aggregate_db_storage_type: :elasticsearch }, elasticsearch_store.aggregated_attribute_handlers[:names].element_helper.options)
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

          @instance.names = ['manny', 'moe', 'jack']
          assert_equal ['manny', 'moe', 'jack'], @instance.names
        end

        should "allow lists to be saved to disk" do
          @store.send(:define_method, :aggregate_owner) { @aggregate_owner ||= OwnerStub.new }
          @store.send(:define_method, :decoded_aggregate_store) { { "names" => nil } }
          @store.send(:define_method, :new_record?) { @new_record }
          @store.send(:define_method, :run_callbacks) { |_foo| true }
          @instance = @store.new

          @instance.names = ['manny', 'moe', 'jack']
          assert_equal ['manny', 'moe', 'jack'], @instance.names

          expected = { "names" => ['manny', 'moe', 'jack'] }

          assert_equal expected, @instance.to_store
        end

        should "allow lists to be loaded from to disk" do
          @store.send(:define_method, :aggregate_owner) { @aggregate_owner ||= OwnerStub.new }
          @store.send(:define_method, :decoded_aggregate_store) { { "names" => ['manny', 'moe', 'jack'] } }
          @store.send(:define_method, :new_record?) { @new_record }
          @store.send(:define_method, :run_callbacks) { |_foo| true }
          @instance = @store.new

          assert_equal ['manny', 'moe', 'jack'], @instance.names
        end

        context "lists of aggregates" do
          setup do
            @agg = Class.new(Aggregate::Base) { }
            @agg.attribute(:name, :string)
            @agg.attribute(:address, :string)
            @agg.attribute(:zip, :integer)
            # rubocop:disable Naming/ConstantName:
            silence_warnings { ::MyTestClass = @agg }
            # rubocop:enable Naming/ConstantName:
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
        context "using stub class" do
          setup do
            @store = Class.new
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

          should "pass aggregate_db_storage_type option to foreign key attribute handler if aggregate_db_storage_type is not nil" do
            elasticsearch_store.aggregate_belongs_to(:passport, class_name: "Passport")
            elasticsearch_store.send(:define_method, :aggregate_owner) { @aggregate_owner ||= OwnerStub.new }

            expected_options = { class_name: "Passport", aggregate_db_storage_type: :elasticsearch }
            assert_equal expected_options, elasticsearch_store.aggregated_attribute_handlers[:passport].options
          end
        end

        context "using flights model" do
          setup do
            @p_millie = Passport.create!(
              name: "Millie",
              gender: :female,
              birthdate: Time.parse("2011-8-11"),
              city: "Santa Barbara",
              state: "California"
            )

            @p_lisa = Passport.create!(
              name: "Lisa",
              gender: :female,
              birthdate: Time.parse("1998-7-18"),
              city: "Santa Barbara",
              state: "California"
            )

            @p_bob = Passport.create!(
              name: "Bob",
              gender: :female,
              birthdate: Time.parse("1998-7-18"),
              city: "Santa Barbara",
              state: "California"
            )

            @flight = Flight.create!(
              flight_number: "123xy",
              passengers: [{ name: "Millie", passport: @p_millie }, { name: "Lisa", passport: @p_lisa }, { name: "Bob", passport: @p_bob }]
            )
          end

          should "find the passports when loaded" do
            reloaded_flight = Flight.find(@flight.id)
            assert_equal 3, reloaded_flight.passengers.size

            assert_equal "Millie", reloaded_flight.passengers[0].name
            assert_equal "Lisa",   reloaded_flight.passengers[1].name
            assert_equal "Bob",    reloaded_flight.passengers[2].name

            assert_equal "Millie", reloaded_flight.passengers[0].passport.name
            assert_equal "Lisa",   reloaded_flight.passengers[1].passport.name
            assert_equal "Bob",    reloaded_flight.passengers[2].passport.name
          end

          should "be able to return the passport_ids without loading the passport models" do
            Passport.initialization_count = 0

            reloaded_flight = Flight.find(@flight.id)
            assert_equal 0, Passport.initialization_count

            assert_equal [@p_millie.id, @p_lisa.id, @p_bob.id], reloaded_flight.passengers.*.passport_id
            assert_equal 0, Passport.initialization_count
          end
        end
      end

      context "schema versioning" do
        should "allow a schema version to be defined." do
          @store = Class.new
          [:save, :save!, :create_or_update, :create, :update, :destroy, :valid?].each do |method|
            @store.send(:define_method, method) { raise "call #{method} on containing class" }
          end

          callbacks_module = RailsUpgradeHelpers::Version.if_version(
            rails_4: -> { ActiveRecord::Callbacks },
            rails_5: -> { ActiveSupport::Callbacks }
          )

          @store.send(:include, Aggregate::AggregateStore)
          @store.send(:include, callbacks_module)
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
    end
  end
end
