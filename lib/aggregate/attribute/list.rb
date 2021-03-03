# frozen_string_literal: true

class Aggregate::Attribute::List < Aggregate::Attribute::Base
  attr_accessor :name, :element_helper

  def self.available_options
    super + [
      :collapse_errors # Put errors on containing object
    ]
  end

  def initialize(name, element_helper, options)
    super(name, options)
    @element_helper = element_helper
    @list = []
  end

  def from_value(value)
    assert_is_list(value)
    value&.map { |v| @element_helper.from_value(v) } || []
  end

  def from_store(value)
    assert_is_list(value)
    value&.map { |v| @element_helper.from_store(v) } || []
  end

  def to_store(value)
    assert_is_list(value)
    value&.map { |v| @element_helper.to_store(v) } || []
  end

  def force_validation?
    @element_helper.force_validation?
  end

  def default
    []
  end

  def validation_errors(value)
    assert_is_list(value)

    contained_errors = (value || []).map { |v| @element_helper.validation_errors(v) }.flatten.compact
    if options[:collapse_errors]
      contained_errors.uniq
    else
      [
        ("is invalid" unless contained_errors.empty?)
      ].compact
    end
  end

  def assert_is_list(value)
    (!value || value.is_a?(Array)) or raise "wrong value type #{value.inspect}"
  end

  def set_saved_changes(agg_value)
    agg_value.each do |value|
      value.try(:set_saved_changes)
    end
  end
end
