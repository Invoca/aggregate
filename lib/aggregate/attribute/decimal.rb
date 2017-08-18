class Aggregate::Attribute::Decimal < Aggregate::Attribute::Builtin
  def load(value)
    BigDecimal.new(value)
  end

  def store(value)
    value.to_s
  end

  def assign(value)
    BigDecimal.new(value.to_s.presence || 0)
  end
end
