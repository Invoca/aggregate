# frozen_string_literal: true

module Aggregate
  module Attribute
    class Builtin < Aggregate::Attribute::Base
      def from_value(value)
        unless value.nil?
          assign(value)
        end
      end

      def from_store(value)
        unless value.nil?
          load(value)
        end
      end

      def to_store(value)
        unless value.nil?
          store(value)
        end
      end

      def new(*args)
        assign(*args)
      end
    end
  end
end
