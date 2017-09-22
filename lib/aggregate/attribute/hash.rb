module Aggregate
  module Attribute
    class Hash < Aggregate::Attribute::Builtin
      DEFAULT_VALUE = {}

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
        convert_to_json(value)
      end

      def assign(value)
        convert_to_hash(value)
      end

      def default
        super || DEFAULT_VALUE
      end

      private

      def convert_to_hash(value)
        if value.nil?
          DEFAULT_VALUE
        elsif value.is_a?(::String)
          if value.blank?
            DEFAULT_VALUE
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
    end
  end
end
