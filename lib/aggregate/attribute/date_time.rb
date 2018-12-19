# frozen_string_literal: true

class Aggregate::Attribute::DateTime < Aggregate::Attribute::Builtin
  def self.available_options
    super + [:format]
  end

  def load(value)
    ActiveSupport::TimeZone['UTC'].parse(value).in_time_zone
  end

  def store(value)
    if @options[:format]
      value.utc.to_s(@options[:format])
    elsif @options.dig(:aggregate_db_storage_type) == :elasticsearch
      value.utc.iso8601
    else
      value.utc.rfc822
    end
  end

  def assign(value)
    if value.is_a?(String)
      Time.zone.parse(value)
    else
      value
    end
  end
end
