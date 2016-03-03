class Aggregate::Attribute::String < Aggregate::Attribute::Builtin

  def self.available_options
    Aggregate::Attribute::Builtin.available_options + [
      :size,  # The maximum length of the string
    ]
  end

  def load(value)
    value.to_s
  end

  def store(value)
    value
  end

  def assign(value)
    value.to_s
  end

  def validation_errors(value)
    super + [
      ("#{value.class} is too long (maximum is #{options[:size]} characters)" if !options[:size].nil? && value.to_s.size > options[:size]  )
    ].compact
  end
end
