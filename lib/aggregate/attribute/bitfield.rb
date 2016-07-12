class Aggregate::Attribute::Bitfield < Aggregate::Attribute::Base

  def self.available_options
    super + [
      :limit
    ]
  end

  def from_value(value)
    klass.new(value || "")
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
  def validation_errors(value)
    []
  end

  private

  def klass
    @klass ||= options[:limit] ? Aggregate::Bitfield.limit(options[:limit]) : Aggregate::Bitfield
  end
end
