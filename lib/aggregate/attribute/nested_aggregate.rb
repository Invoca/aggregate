# frozen_string_literal: true

class Aggregate::Attribute::NestedAggregate < Aggregate::Attribute::Base
  attr_reader :class_name

  def initialize(name, class_name, options)
    super(name, options)
    @class_name = class_name.to_s
  end

  def from_value(value)
    unless value.nil?
      if value.is_a?(klass)
        value
      else
        klass.new(value)
      end
    end
  end

  def from_store(value)
    unless value.nil?
      klass.from_store(value)
    end
  end

  def to_store(value)
    value&.to_store
  end

  def new(*args)
    klass.new(*args)
  end

  def validation_errors(value)
    super + [
      (value.errors.to_a.map { |v| [v].flatten.join(" ") } if value && !value.valid?)
    ].flatten.compact
  end

  private

  def klass
    @klass ||= class_name.to_s.constantize
  end
end
