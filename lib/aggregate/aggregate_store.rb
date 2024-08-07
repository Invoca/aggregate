# frozen_string_literal: true

module Aggregate
  module AggregateStore
    REQUIRED_METHODS = [:aggregate_owner, :decoded_aggregate_store, :new_record?, :errors, :run_callbacks].freeze

    module ClassMethods
      def aggregate_attribute(name, class_name, options = {})
        agg_attribute = Aggregate::AttributeHandler.factory(name, class_name, full_attr_handler_options(options))
        aggregated_attribute_handlers[name] = agg_attribute

        define_method(name)                       { load_aggregate_attribute(agg_attribute) }
        define_method("#{name}=")                 { |value| save_aggregate_attribute(agg_attribute, value) }
        define_method("#{name}_changed?")         { aggregate_attribute_changed?(agg_attribute) }
        define_method("build_#{name}")            { |*args| save_aggregate_attribute(agg_attribute, agg_attribute.new(*args)) }
        define_method("#{name}_before_type_cast") { aggregate_attribute_before_type_cast(agg_attribute) }
        define_method("saved_change_to_#{name}?") { aggregate_attribute_saved_changed?(agg_attribute) }
      end

      def aggregate_has_many(name, class_name, options = {})
        agg_attribute = Aggregate::AttributeHandler.has_many_factory(name, class_name, full_attr_handler_options(options))
        aggregated_attribute_handlers[name] = agg_attribute

        define_method(name)                       { load_aggregate_attribute(agg_attribute) }
        define_method("#{name}=")                 { |value| save_aggregate_attribute(agg_attribute, value) }
        define_method("#{name}_changed?")         { aggregate_attribute_changed?(agg_attribute) }
        define_method("saved_change_to_#{name}?") { aggregate_attribute_saved_changed?(agg_attribute) }
      end

      def aggregate_belongs_to(name, options = {})
        agg_attribute = Aggregate::AttributeHandler.belongs_to_factory("#{name}_id", full_attr_handler_options(options))
        aggregated_attribute_handlers[name] = agg_attribute

        define_method(name)                       { load_aggregate_attribute(agg_attribute)&.value }
        define_method("#{name}_id")               { load_aggregate_attribute(agg_attribute)&.id }
        define_method("#{name}=")                 { |value| save_aggregate_attribute(agg_attribute, value) }
        define_method("#{name}_id=")              { |value| save_aggregate_attribute(agg_attribute, value) }
        define_method("#{name}_changed?")         { aggregate_attribute_changed?(agg_attribute) }
      end

      def aggregate_schema_version(version_number, update_callback)
        aggregated_attribute_handlers[name] = agg_attribute = Aggregate::Attribute::SchemaVersion.new(version_number, update_callback)
        define_method("data_schema_version") { load_aggregate_attribute(agg_attribute) }

        set_callback(:aggregate_load_check_schema, :after, :check_schema_version)
        define_method(:check_schema_version) do
          if data_schema_version != version_number
            send(update_callback, data_schema_version)
          end
        end
      end

      def aggregated_attribute_handlers
        @aggregated_attribute_handlers ||=
          if superclass.respond_to?(:aggregated_attribute_handlers)
            superclass.aggregated_attribute_handlers.dup
          else
            {}
          end
      end

      # Defined to be optionally overwritten
      def aggregate_db_storage_type; end

      # Defined to be optionally overwritten
      #
      # If the decoded aggregate store (serialized data) is missing the aggregate attribute key, what value
      # should be returned? If this method returns truthy, it should return the attribute's default value.
      # If this method returns falsey, it should return nil.
      # See #load_aggregate_attribute for more details on how it's used.
      def aggregate_treat_undefined_attributes_as_default_value?; end

      private

      def full_attr_handler_options(options)
        options.merge({ aggregate_db_storage_type: aggregate_db_storage_type }.compact)
      end
    end

    def self.included(model_class)
      attr_accessor :aggregate_list

      model_class.extend ClassMethods
    end

    def changed_for_autosave?
      defined?(super) or raise NoMethodError, "undefined method 'changed_for_autosave?' for #{self}"
      super || @changed
    end

    def changed?
      (defined?(super) && super) || @changed
    end

    def saved_changes?
      ensure_saved_changes_up_to_date
      (defined?(super) && super) || @changed_on_save
    end

    def set_changed
      @changed = aggregate_values != aggregate_initial_values
      aggregate_owner&.set_changed
    end

    def set_saved_changes
      @changed_on_save = @changed
      @saved_aggregate_changes = aggregate_attribute_changes
      set_saved_changes_child_attributes
    end

    def to_store
      self.class.aggregated_attribute_handlers.build_hash do |_, aa|
        agg_value = load_aggregate_attribute(aa)

        # Optimization: only write out values if they are not nil, if there is no schema migration and
        # the default value is nil. (Schema migrations and defaults depend on writing the value.)
        if respond_to?(:data_schema_version) || !aa.default.nil? || !agg_value.nil?
          [aa.name, aa.to_store(agg_value)]
        end
      end
    end

    def validate_aggregates
      self.class.aggregated_attribute_handlers.each do |_, aa|
        if new_record? || aa.force_validation? || aggregate_attribute_loaded?(aa) || aggregate_attribute_changed?(aa)
          aa.validation_errors(load_aggregate_attribute(aa)).each do |error|
            errors.add(aa.name, error)
          end
        end
      end
    end

    def inspect_aggregates(level = 1)
      self.class.aggregated_attribute_handlers.map do |_, aa|
        value = load_aggregate_attribute(aa)
        "#{'    ' * level}:#{aa.name} => #{value.respond_to?(:inspect_aggregates) ? "\n" + value.inspect_aggregates(level + 1) : value.inspect}"
      end.join("\n")
    end

    def aggregate_attributes
      self.class.aggregated_attribute_handlers.build_hash do |_, attr|
        value  = load_aggregate_attribute(attr)
        result = value.is_a?(Aggregate::AggregateStore) ? value.aggregate_attributes : value
        [attr.name, result]
      end
    end

    def aggregate_attribute_changes
      aggregate_changes.build_hash do |field, changed|
        changed or next
        [field, [aggregate_initial_values[field], aggregate_values_before_cast[field]]]
      end
    end

    def aggregate_attribute_saved_changes
      ensure_saved_changes_up_to_date
      @saved_aggregate_changes || {}
    end

    def get_aggregate_attribute(name)
      agg_attribute_handler = self.class.aggregated_attribute_handlers[name.to_sym]
      load_aggregate_attribute(agg_attribute_handler)
    end

    def set_aggregate_attribute(name, value)
      agg_attribute_handler = self.class.aggregated_attribute_handlers[name.to_sym]
      save_aggregate_attribute(agg_attribute_handler, value)
    end

    private

    def load_aggregate_attribute(agg_attribute)
      unless aggregate_values.key?(agg_attribute.name)
        value = load_aggregate_from_store?(agg_attribute) ? load_aggregate_from_store(agg_attribute) : agg_attribute.default
        aggregate_values[agg_attribute.name] = value
        aggregate_initial_values[agg_attribute.name] = value

        # Fire the callback.  It MAY change the value, so fetch again from the hash.
        notify_if_first_access
      end
      aggregate_values[agg_attribute.name]
    end

    # Returns truthy if the value of the attribute should be loaded from the decoded aggregate store (serialized data).
    # Returns falsey if the attribute should use its default value.
    def load_aggregate_from_store?(agg_attribute)
      decoded_aggregate_store &&
        (decoded_aggregate_store.try(:key?, agg_attribute.name.to_s) || !self.class.aggregate_treat_undefined_attributes_as_default_value?)
    end

    def notify_if_first_access
      unless @notify_if_first_access_done
        @notify_if_first_access_done = true
        run_callbacks(:aggregate_load_check_schema)
        run_callbacks(:aggregate_load)
      end
    end

    def save_aggregate_attribute(agg_attribute, value)
      aggregate = agg_attribute.from_value(value)
      if aggregate != load_aggregate_attribute(agg_attribute)
        name = agg_attribute.name
        aggregate_values_before_cast[name] = value
        aggregate_values[name]             = aggregate
        aggregate_changes[name]            = aggregate != aggregate_initial_values[name]
        set_aggregate_owner(agg_attribute, aggregate)
        set_changed
      end
      value
    end

    def aggregate_attribute_changed?(agg_attribute)
      aggregate_changes[agg_attribute.name] || Array.wrap(aggregate_values[agg_attribute.name]).any? { |value| value.try(:changed?) }
    end

    def aggregate_attribute_saved_changed?(agg_attribute)
      ensure_saved_changes_up_to_date
      aggregate_attribute_saved_changes.include?(agg_attribute.name) ||
        Array.wrap(aggregate_values[agg_attribute.name]).any? { |value| value.try(:saved_changes?) }
    end

    def aggregate_attribute_before_type_cast(agg_attribute)
      load_aggregate_attribute(agg_attribute)
      aggregate_values_before_cast[agg_attribute.name] || aggregate_initial_values[agg_attribute.name]
    end

    def load_aggregate_from_store(agg_attribute)
      agg_attribute.from_store(decoded_aggregate_store[agg_attribute.name.to_s]).tap do |aggregate|
        set_aggregate_owner(agg_attribute, aggregate)
      end
    end

    def aggregate_values
      @aggregate_values ||= {}
    end

    def aggregate_initial_values
      @aggregate_initial_values ||= {}
    end

    def aggregate_changes
      @aggregate_changes ||= {}
    end

    def aggregate_values_before_cast
      @aggregate_values_before_cast ||= {}
    end

    def aggregate_attribute_loaded?(agg_attribute)
      aggregate_initial_values.key?(agg_attribute.name)
    end

    def set_aggregate_owner(_agg_attribute, aggregate_value)
      [aggregate_value].flatten.each { |v| v.try(:aggregate_owner=, self) }
    end

    def set_saved_changes_child_attributes
      self.class.aggregated_attribute_handlers.each do |_, aa|
        agg_value = load_aggregate_attribute(aa)
        aa.assign_saved_changes(agg_value)
      end
    end

    def start_save
      @aggregate_save_in_progress = true
    end

    def end_save
      @aggregate_save_in_progress = false
    end

    def save_changes
      set_saved_changes
      end_save
    end

    def ensure_saved_changes_up_to_date
      if @aggregate_save_in_progress
        save_changes
      end
    end
  end
end
