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
    end

    def aggregate_owner
      nil
    end

    def decoded_aggregate_store
      unless @decoded_aggregate_store_loaded
        @decoded_aggregate_store = aggregate_store.presence && ActiveSupport::JSON.decode(aggregate_store)
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
        self.aggregate_store =
          if has_schema_version? || any_non_default_values?
            ActiveSupport::JSON.encode(to_store)
          else
            ''
          end
      end
    end
  end
end
