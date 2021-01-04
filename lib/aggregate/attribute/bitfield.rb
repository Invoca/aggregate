# frozen_string_literal: true

class Aggregate::Attribute::Bitfield < Aggregate::Attribute::Base
  DEFAULT_OPTIONS = {
    mapping: { "t" => true, "f" => false, " " => nil },
    default: nil
  }.freeze

  def self.available_options
    super + [
      :limit,
      :mapping,
      :default
    ]
  end

  def initialize(name, options = {})
    super(name, DEFAULT_OPTIONS.deep_merge(options))
    assert_valid_mapping_and_default
  end

  def from_value(value)
    klass.new(value_to_string(value) || "")
  end

  def from_store(value)
    klass.new(value || "")
  end

  def to_store(value)
    value.to_s if value && value != ""
  end

  def default
    klass.new("")
  end

  # Overrides default
  def validation_errors(_value)
    []
  end

  private

  def value_to_string(value)
    value.respond_to?(:map) ? value.map { |v| klass.to_bit(v) }.join : value&.to_s
  end

  def klass
    @klass ||= Aggregate::Bitfield.with_options(options)
  end

  def assert_valid_mapping_and_default
    mapping = options[:mapping]
    default = options[:default]
    mapping.presence.is_a?(Hash) or raise ArgumentError, "mapping must be provided as a hash"

    values = mapping.values
    values.count == values.uniq.count or raise ArgumentError, "mapping must have unique values"
    default.in?(values) or raise ArgumentError, "default value not provided in mapping"
  end
end
