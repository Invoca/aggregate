# frozen_string_literal: true

class Aggregate::Attribute::Integer < Aggregate::Attribute::Builtin
  def load(value)
    value.to_i
  end

  def store(value)
    value
  end

  def assign(value)
    value.to_i
  end
end
