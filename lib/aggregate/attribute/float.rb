# frozen_string_literal: true

class Aggregate::Attribute::Float < Aggregate::Attribute::Builtin
  def load(value)
    value.to_f
  end

  def store(value)
    value.to_f
  end

  def assign(value)
    value
  end
end
