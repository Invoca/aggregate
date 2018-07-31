# frozen_string_literal: true

class Aggregate::Attribute::Enum < Aggregate::Attribute::Builtin
  def load(value)
    value.to_sym
  end

  def store(value)
    value.to_s
  end

  def assign(value)
    value.to_sym if value.present?
  end
end
