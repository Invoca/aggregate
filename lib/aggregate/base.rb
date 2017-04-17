module Aggregate
  class Base
    attr_accessor :decoded_aggregate_store, :aggregate_owner # , :aggregate_store

    include Aggregate::AggregateStore

    # These need to be defined after the store is included, but before the ActiveRecord modules
    [:save, :save!, :create_or_update, :create, :update, :destroy].each do |method|
      define_method(method) { raise "call #{method} on containing class" }
    end

    include ActiveRecord::Validations
    include ActiveRecord::Callbacks
    include ActiveRecord::Reflection
    include Comparable

    validate :validate_aggregates

    define_callbacks :before_validation, :aggregate_load, :aggregate_load_check_schema

    def initialize(arguments = {})
      arguments.each { |k, v| send("#{k}=", v) }
    end

    def <=>(other)
      self.class.aggregated_attributes.map_and_find do |attr|
        compare(send(attr.name), other.send(attr.name)).nonzero?
      end || 0
    end

    def self.secret_keys_from_config
      if Aggregate.configuration.keys_list.is_a?(Array)
        Aggregate.configuration.keys_list.map {|key| Base64.strict_decode64(key)}
      elsif Aggregate.configuration.keys_list.is_a?(String)
        [ Base64.strict_decode64(Aggregate.configuration.keys_list) ]
      else
        []
      end
    end

    def root_aggregate_owner
      !aggregate_owner ? self : aggregate_owner.root_aggregate_owner
    end

    def self.from_store(decoded_aggregate_store)
      new.tap { |instance| instance._set_store(decoded_aggregate_store) }
    end

    def self.from_json(hash)
      decoded_hash = hash.presence && ActiveSupport::JSON.decode(hash)
      new.tap { |instance| instance._set_store(decoded_hash.presence, false) }
    end

    def to_json
      ActiveSupport::JSON.encode(to_store)
    end

    alias_method :to_hash, :to_store

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
    def respond_to_without_attributes?(*_args)
    end

    # Methods required by error messages for
    def self.self_and_descendants_from_active_record
      [self]
    end

    def self.human_name
      to_s.humanize
    end

    def self.human_attribute_name(attribute, _options = {})
      attribute.to_s.humanize
    end

    def _set_store(decoded_aggregate_store, from_store = true)
      self.decoded_aggregate_store = decoded_aggregate_store
      @loaded_from_store = from_store
    end

    private

    def compare(right, left)
      safe_compare(right) <=> safe_compare(left)
    end

    def safe_compare(value)
      case value
      when NilClass
        [3, 0]
      when TrueClass
        [2, 1]
      when FalseClass
        [2, 0]
      when Symbol
        [1, value.to_s]
      else
        [0, value]
      end
    end
  end
end
