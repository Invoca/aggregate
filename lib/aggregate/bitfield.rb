# A string representation of a fixed length array of nillable booleans.
# A length limited version of the class is created by calling the limit method.
module Aggregate
  class Bitfield
    include Comparable

    def initialize(string_form)
      @string = string_form
    end

    def [](index)
      check_index_limit(index)
      to_boolean(@string[index])
    end

    def []=(index, value)
      check_index_limit(index)
      @string = @string.ljust(index)
      @string[index] = to_character(value)
    end

    def to_s
      @string.rstrip
    end

    def <=>(other)
      self.to_s <=> other.to_s
    end


    private
    def to_character(boolean)
      case boolean
      when true
        "t"
      when false
        "f"
      when nil
        " "
      end
    end

    def to_boolean(character)
      case character
      when 't'
        true
      when 'f'
        false
      when ' ', nil
        nil
      else
        raise "Unexpeced value in bitfield: (#{@string.inspect})"
      end
    end

    protected
    def check_index_limit(index)
      # Derived classes overwrite this to enforce their limits
    end

    def self.limit(limit)
      limited_class = "Aggregate::Bitfield_Limit_#{limit}"
      unless Object.const_defined?(limited_class)
        instance_eval <<-EOC
          class #{limited_class} < Aggregate::Bitfield
            def check_index_limit(index)
              if index >= #{limit}
                raise ArgumentError, "index out of bounds, index(\#{index}) >= limit(#{limit})"
              end
            end
          end
        EOC
      end
      limited_class.constantize
    end
  end
end