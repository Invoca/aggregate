module Aggregate
  class AttributeHandler < Struct.new(:name, :class_name, :options)
    BUILTIN_TYPES = {
      'string'    => Aggregate::Attribute::String,
      'integer'   => Aggregate::Attribute::Integer,
      'float'     => Aggregate::Attribute::Float,
      'boolean'   => Aggregate::Attribute::Boolean,
      'enum'      => Aggregate::Attribute::Enum,
      'datetime'  => Aggregate::Attribute::DateTime,
      'decimal'   => Aggregate::Attribute::Decimal,
    }

    def self.factory( name, class_name, options )
      if handler_class = BUILTIN_TYPES[class_name.to_s]
        handler_class.new(name, options)
      else
        Aggregate::Attribute::NestedAggregate.new(name, class_name, options)
      end
    end

    def self.has_many_factory( name, class_name, options )
      collapse_errors = options.delete(:collapse_errors)
      Aggregate::Attribute::List.new(name,factory("element", class_name, options), :collapse_errors => collapse_errors)
    end

    def self.belongs_to_factory( name, options )
      Aggregate::Attribute::ForeignKey.new( name, options )
    end
  end
end
