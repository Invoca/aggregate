# frozen_string_literal: true

require 'large_text_field'

module Aggregate
  module Container
    extend ActiveSupport::Concern
    include ActiveSupport::Callbacks
    include Aggregate::AggregateStore

    class StorageAlreadyDefined < ArgumentError; end

    # rubocop:disable Metrics/BlockLength
    included do
      validate :validate_aggregates
      send(:define_callbacks, :aggregate_load)
      send(:define_callbacks, :aggregate_load_schema)
      send(:define_callbacks, :aggregate_load_check_schema)
      set_callback :commit, :after, :reset_changed_cache
      class_attribute :aggregate_storage_field
      class_attribute :migrate_from_storage_field

      class << self
        def store_aggregates_using_large_text_field
          raise_if_aggregate_storage_field_already_defined
          include LargeTextField::Owner
          large_text_field :aggregate_store
          self.aggregate_storage_field = :aggregate_store
          self.migrate_from_storage_field = nil
          set_callback(:large_text_field_save, :before, :write_aggregates)
          set_callback(:destroy, :before, :decoded_aggregate_store, prepend: true)
        end

        def store_aggregates_using(storage_field, migrate_from_storage_field: nil)
          raise_if_aggregate_storage_field_already_defined
          self.aggregate_storage_field = storage_field
          self.migrate_from_storage_field = migrate_from_storage_field
          set_callback(:save, :before, :write_aggregates)
        end

        private

        def raise_if_aggregate_storage_field_already_defined
          if aggregate_storage_field
            raise StorageAlreadyDefined, "aggregate_storage_field is already set to #{aggregate_storage_field.inspect}"
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength

    def aggregate_owner
      nil
    end

    def decoded_aggregate_store
      unless @decoded_aggregate_store_loaded
        @decoded_aggregate_store = aggregate_store_data.presence && ActiveSupport::JSON.decode(aggregate_store_data)
        @decoded_aggregate_store_loaded = true
      end
      @decoded_aggregate_store
    end

    def root_aggregate_owner
      self
    end

    def any_non_default_values?
      aggregate_attributes != self.class.new.aggregate_attributes
    end

    def schema_version?
      respond_to?(:data_schema_version)
    end

    def write_aggregates
      self.class.aggregate_storage_field or raise "Must call store_aggregates_using or store_aggregates_using_large_text_field"
      if @decoded_aggregate_store_loaded
        encoded_data = if schema_version? || any_non_default_values?
                         ActiveSupport::JSON.encode(to_store)
                       else
                         ''
                       end

        send("#{self.class.aggregate_storage_field}=", encoded_data)
      end
    end

    def reload
      result = super
      reset_cache_data
      result
    end

    private

    def reset_cache_data
      @decoded_aggregate_store_loaded = nil
      @aggregate_values = nil
      @aggregate_initial_values = nil
      @aggregate_values_before_cast = nil
      reset_changed_cache
    end

    def reset_changed_cache
      @changed = nil
      @aggregate_changes = nil
    end

    def aggregate_store_data
      read_store_from_field(self.class.aggregate_storage_field) ||
        read_store_from_field(self.class.migrate_from_storage_field)
    end

    def read_store_from_field(field)
      if field && (field_data = send(field)) && field_data.present?
        field_data
      end
    end
  end
end
