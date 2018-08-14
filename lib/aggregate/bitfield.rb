# frozen_string_literal: true

# A string representation of a fixed length array of values defined in a provided mapping of characters
# to values.
# A length limited version of the class is created by calling the limit method.
module Aggregate
  class Bitfield
    include Comparable

    def initialize(string_form, mapping:, default:)
      @string            = string_form
      @value_mapping     = mapping
      @bit_mapping       = mapping.invert
      @default           = default
      @default_bit_value = to_bit(@default)
    end

    def [](index)
      check_index_limit(index)
      from_bit(@string[index])
    end

    def []=(index, value)
      check_index_limit(index)
      @string = @string.ljust(index, @default_bit_value)
      @string[index] = to_bit(value)
    end

    def to_s
      @string.gsub(/#{Regexp.escape(@default_bit_value)}+\z/, "")
    end

    def <=>(other)
      to_s <=> other.to_s
    end

    def self.limit(limit)
      limited_class = "Aggregate::Bitfield_Limit_#{limit}"
      unless Object.const_defined?(limited_class)
        instance_eval(<<-CLASS_DEFINITION, __FILE__, __LINE__ + 1)
          class #{limited_class} < Aggregate::Bitfield
            def check_index_limit(index)
              if index >= #{limit}
                raise ArgumentError, "index out of bounds, index(\#{index}) >= limit(#{limit})"
              end
            end
          end
        CLASS_DEFINITION
      end
      limited_class.constantize
    end

    private

    def to_bit(original_value)
      @bit_mapping[original_value]
    end

    def from_bit(bit_value)
      @value_mapping.key?(bit_value) or raise "Unexpected value in bitfield: (#{@string.inspect})"
      @value_mapping[bit_value]
    end

    protected

    def check_index_limit(index)
      # Derived classes overwrite this to enforce their limits
    end
  end
end
