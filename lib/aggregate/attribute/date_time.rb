class Aggregate::Attribute::DateTime < Aggregate::Attribute::Builtin
  def load(value)
    ActiveSupport::TimeZone['UTC'].parse(value).in_time_zone
  end

  def store(value)
    value.utc.rfc822
  end

  def assign(value)
    if value.is_a?(String)
      Time.zone.parse(value)
    else
      value
    end
  end
end
