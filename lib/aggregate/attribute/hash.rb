# frozen_string_literal: true

module Aggregate
  module Attribute
    class Hash < Aggregate::Attribute::Builtin
      DEFAULT_VALUE = {}.freeze

      # :store_hash_as_json option defaults to true

      class << self
        def available_options
          super + [:store_hash_as_json]
        end
      end

      def from_value(value)
        super || DEFAULT_VALUE
      end

      def from_store(value)
        super || DEFAULT_VALUE
      end

      def to_store(value)
        super || DEFAULT_VALUE.to_json
      end

      def load(value)
        convert_to_hash(value)
      end

      def store(value)
        if should_store_hash_as_json
          convert_to_json(value)
        else
          convert_to_hash(value)
        end
      end

      def assign(value)
        convert_to_hash(value)
      end

      def default
        (super || DEFAULT_VALUE).dup
      end

      private

      def convert_to_hash(value)
        if value.nil?
          DEFAULT_VALUE.dup
        elsif value.is_a?(::String)
          if value.blank?
            DEFAULT_VALUE.dup
          else
            ActiveSupport::JSON.decode(value)
          end
        elsif value.respond_to?(:to_hash)
          value.to_hash
        else
          value
        end
      end

      def convert_to_json(value)
        if value.is_a?(::String)
          value
        else
          ActiveSupport::JSON.encode(value || DEFAULT_VALUE)
        end
      end

      def should_store_hash_as_json
        options[:store_hash_as_json].nil? || options[:store_hash_as_json]
      end
    end
  end
end
