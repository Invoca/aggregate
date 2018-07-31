# frozen_string_literal: true

class Aggregate::Attribute::ForeignKey < Aggregate::Attribute::Base

  def self.available_options
    super + [
      :class_name # The class for the foreign key
    ]
  end

  def from_value(value)
    if value.is_a?(ActiveRecord::Base)
      value
    elsif value.nil?
      nil
    else
      klass.find(value)
    end
  end

  def from_store(value)
    klass.find(value) if value
  end

  def to_store(value)
    value&.id
  end

  private

  def klass
    @klass ||= options[:class_name].to_s.constantize
  end
end
