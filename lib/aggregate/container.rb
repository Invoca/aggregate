require 'large_text_field'

module Aggregate
  module Container
    extend ActiveSupport::Concern
    include LargeTextField::Owner
    include Aggregate::AggregateStore

    included do
      large_text_field :aggregate_store
      set_callback(:large_text_field_save, :before, :write_aggregates)
      validate :validate_aggregates
      send(:define_callbacks, :aggregate_load)
      send(:define_callbacks, :aggregate_load_schema)
      send(:define_callbacks, :aggregate_load_check_schema)
      class_attribute :aggregate_container_options
      self.aggregate_container_options = {
          use_storage_field: nil,
          use_large_text_field_as_failover: false
      }
    end

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

    def has_schema_version?
      respond_to?(:data_schema_version)
    end

    def write_aggregates
      if @decoded_aggregate_store_loaded
        encoded_data = if has_schema_version? || any_non_default_values?
                         ActiveSupport::JSON.encode(to_store)
                       else
                         ''
                       end

        send("#{aggregate_storage_field}=", encoded_data)
      end
    end


    def uses_aggregate_storage_field?
      !!self.class.aggregate_container_options[:use_storage_field].presence
    end

    def aggregate_storage_field
      if uses_aggregate_storage_field?
        self.class.aggregate_container_options[:use_storage_field]
      else
        :aggregate_store
      end
    end

    def failover_to_large_text_field?
      !!(uses_aggregate_storage_field? && self.class.aggregate_container_options[:use_large_text_field_as_failover])
    end

    private

    def aggregate_store_data
      if (field_data = send(aggregate_storage_field)) && field_data.present?
        field_data
      elsif failover_to_large_text_field?
        self.aggregate_store
      end
    end
  end
end
