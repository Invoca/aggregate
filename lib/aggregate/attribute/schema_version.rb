# frozen_string_literal: true

class Aggregate::Attribute::SchemaVersion < Aggregate::Attribute::Base

  attr_reader :code_version, :fixup_method

  def initialize(code_version, fixup_method)
    super("data_schema_version", {})
    @code_version = code_version
    @fixup_method = fixup_method
  end

  def from_value(value)
    value&.to_s
  end

  def from_store(value)
    value&.to_s
  end

  def to_store(_value)
    code_version.to_s
  end
end
