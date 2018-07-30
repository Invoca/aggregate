# frozen_string_literal: true

class Aggregate::Attribute::Decimal < Aggregate::Attribute::Builtin
  def load(value)
    value.to_d
  rescue ArgumentError
    BigDecimal(0)
  end

  def store(value)
    value.to_s
  end

  def assign(value)
    value.to_d
  rescue ArgumentError
    BigDecimal(0)
  end
end
