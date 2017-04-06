# class Aggregate::Attribute::Base

module Aggregate
  module Attribute
    class Base

      def self.available_options
        [
          :default,          # The default value for this attribute.  Default is nil.
          :limit,            # Specifies the allowed values for this attribute.
          :required,         # If true, this attribute cannot be nil, default is false.
          :force_validation, # If true, this attribute will be validated even if it was not loaded, default is false.
        ]
      end

      attr_accessor :name, :options

      def initialize(name, options)
        @name = name.to_s
        @options = options
        options.assert_valid_keys(*self.class.available_options)
      end

      def from_value(_value)
        raise NotImplemented
      end

      def from_store(_value)
        raise NotImplemented
      end

      def to_store(_value)
        raise NotImplemented
      end

      def to_store_encrypted
        raise NotImplemented
      end

      def from_store_decrypted
        raise NotImplemented
      end

      def new(*_args)
        raise NotImplemented
      end

      def validation_errors(value)
        [
          ("is not in list (#{value.inspect} not in #{options[:limit].inspect})" if value && options[:limit] && !value.in?(options[:limit])),
          ("must be set" if !value && options[:required])
        ].compact
      end

      def default
        if options[:default].is_a?(Proc)
          options[:default].call
        else
          options[:default]
        end
      end

      def force_validation?
        options[:force_validation]
      end
    end
  end
end
