# frozen_string_literal: true

module Aggregate
  module Attribute
    class Boolean < Aggregate::Attribute::Builtin
      def load(value)
        !!value
      end

      def store(value)
        !!value
      end

      def assign(value)
        self.class.convert_to_boolean(value)
      end

      TRUE_VALUES = %w[1 t T true TRUE].to_set

      def self.convert_to_boolean(value)
        if value.is_a?(::String)
          if value.blank?
            nil
          else
            TRUE_VALUES.include?(value)
          end
        else
          !!value
        end
      end
    end
  end
end
