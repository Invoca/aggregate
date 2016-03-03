module Aggregate
  class Base
    attr_accessor :decoded_aggregate_store, :aggregate_owner #, :aggregate_store

    include Aggregate::AggregateStore

    # These need to be defined after the store is included, but before the ActiveRecord modules
    [:save, :save!, :create_or_update, :create, :update, :destroy].each do |method|
      define_method(method) { raise "call #{method} on containing class" }
    end

    include ActiveRecord::Validations
    include ActiveRecord::Callbacks
    include Comparable

    validate :validate_aggregates

    define_callbacks :before_validation, :aggregate_load, :aggregate_load_check_schema

    def initialize(arguments = {})
      arguments.each { |k,v| send( "#{k}=", v ) }
    end

    def <=>(rhs)
      self.class.aggregated_attributes.map_and_find do |attr|
        compare(send(attr.name), rhs.send(attr.name)).nonzero?
      end || 0
    end

    def root_aggregate_owner
      !aggregate_owner ? self : aggregate_owner.root_aggregate_owner
    end

    def self.from_store(decoded_aggregate_store)
      new.tap { |instance| instance._set_store(decoded_aggregate_store) }
    end

    def self.attribute(*args)
      aggregate_attribute(*args)
    end

    def self.has_many(*args)
      aggregate_has_many(*args)
    end

    def self.belongs_to(*args)
      aggregate_belongs_to(*args)
    end

    # These methods are required in order to include validations and callbacks.
    def new_record?
      !@loaded_from_store
    end

    # Required by ActiveRecord::CallBacks
    def respond_to_without_attributes?(*args)
    end

    # Methods required by error messages for
    def self.self_and_descendants_from_active_record
      [self]
    end

    def self.human_name
      self.to_s.humanize
    end

    def self.human_attribute_name(attribute, options={})
      attribute.to_s.humanize
    end

    def _set_store(decoded_aggregate_store)
      self.decoded_aggregate_store = decoded_aggregate_store
      @loaded_from_store = true
    end

    private

    def compare(right,left)
      safe_compare(right) <=> safe_compare(left)
    end

    def safe_compare(value)
      case value
      when NilClass
        [3,0]
      when TrueClass
        [2,1]
      when FalseClass
        [2,0]
      when Symbol
        [1,value.to_s]
      else
        [0,value]
      end
    end
  end
end
