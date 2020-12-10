# frozen_string_literal: true

# A string representation of a fixed length array of values defined in a provided mapping of characters
# to values.
# A length limited version of the class is created by calling the limit method.
module Aggregate
  class Bitfield
    include Comparable

    class << self
      def with_options(options)
        klass_name = "Aggregate::BitfieldWithOptions#{options.hash.to_s.underscore}"
        unless Object.const_defined?(klass_name)
          instance_eval(<<-CLASS_DEFINITION, __FILE__, __LINE__ + 1)
          class #{klass_name} < Aggregate::Bitfield
            cattr_accessor :default, :limit, :value_mapping, :bit_mapping, :default_bit_value
            def initialize(string_form)
              @string = string_form
            end
          end
          CLASS_DEFINITION

          klass                   = klass_name.constantize
          klass.default           = options[:default]
          klass.limit             = options[:limit]
          klass.value_mapping     = options[:mapping]
          klass.bit_mapping       = options[:mapping].invert
          klass.default_bit_value = klass.to_bit(klass.default)
        end
        klass_name.constantize
      end

      def to_bit(original_value)
        bit_mapping[original_value]
      end

      def from_bit(bit_value)
        if bit_value.nil?
          default
        else
          value_mapping.key?(bit_value) or raise "Unexpected value in bitfield: (#{bit_value.inspect})"
          value_mapping[bit_value]
        end
      end

      def check_index_limit(index)
        if limit && index >= limit
          raise ArgumentError, "index out of bounds, index(#{index}) >= limit(#{limit})"
        end
      end
    end

    def initialize(*)
      raise "abstract class cannot be created"
    end

    def [](index)
      self.class.check_index_limit(index)
      self.class.from_bit(@string[index])
    end

    def []=(index, value)
      bit_value = self.class.to_bit(value) or raise ArgumentError, "attempted to set unsupported bitfield value #{value.inspect}"
      self.class.check_index_limit(index)
      @string = @string.ljust(index, self.class.default_bit_value)
      @string[index] = bit_value
    end

    def to_a
      (0...@string.length).map { |i| self.class.from_bit(@string[i]) }
    end

    def to_s
      @string.gsub(/#{Regexp.escape(self.class.default_bit_value)}+\z/, "")
    end

    def <=>(other)
      to_s <=> other.to_s
    end
  end
end
