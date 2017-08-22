class Aggregate::Attribute::Decimal < Aggregate::Attribute::Builtin
  def load(value)
    begin
      value.to_d
    rescue ArgumentError
      BigDecimal(0)
    end
  end

  def store(value)
    value.to_s
  end

  def assign(value)
    begin
      value.to_d
    rescue ArgumentError
      BigDecimal(0)
    end
  end
end
