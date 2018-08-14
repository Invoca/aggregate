# frozen_string_literal: true

class Aggregate::Attribute::Bitfield < Aggregate::Attribute::Base
  DEFAULT_MAPPING = { "t" => true, "f" => false, " " => nil }.freeze
  DEFAULT_VALUE = nil

  def self.available_options
    super + [
      :limit,
      :mapping,
      :default
    ]
  end

  def initialize(name, options)
    super
    assert_valid_mapping_and_default
  end

  def from_value(value)
    new_klass(value&.to_s || "")
  end

  def from_store(value)
    new_klass(value || "")
  end

  def to_store(value)
    value.to_s if value && value != ""
  end

  def default
    new_klass("")
  end

  # Overrides default
  def validation_errors(_value)
    []
  end

  private

  def klass
    @klass ||= options[:limit] ? Aggregate::Bitfield.limit(options[:limit]) : Aggregate::Bitfield
  end

  def new_klass(value)
    klass.new(value, mapping: mapping, default: default_value)
  end

  def mapping
    @mapping ||= options[:mapping] || DEFAULT_MAPPING.dup
  end

  def default_value
    unless defined?(@default_value)
      @default_value = options[:default] || DEFAULT_VALUE.dup
    end
    @default_value
  end

  def assert_valid_mapping_and_default
    mapping.presence.is_a?(Hash) or raise ArgumentError, "mapping must be provided as a hash"

    values = mapping.values
    values.count == values.uniq.count or raise ArgumentError, "mapping must have unique values"
    default_value.in?(values) or raise ArgumentError, "default value not provided in mapping"
  end
end
