# frozen_string_literal: true

class Aggregate::Attribute::Decimal < Aggregate::Attribute::Builtin
  class << self
    def available_options
      (super + [:scale]).freeze
    end
  end

  def load(value)
    if (scale = options[:scale])
      value.to_d.truncate(scale)
    else
      value.to_d
    end
  rescue ArgumentError
    BigDecimal(0)
  end

  def store(value)
    load(value).to_s
  end

  def assign(value)
    load(value)
  end
end
