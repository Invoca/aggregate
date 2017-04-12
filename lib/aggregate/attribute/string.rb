class Aggregate::Attribute::String < Aggregate::Attribute::Builtin

  def self.available_options
    Aggregate::Attribute::Builtin.available_options + [
      :size, # The maximum length of the string
      :encrypted, # Whether or not we need to encrypt a field
    ]
  end

  def load(value)
    options[:encrypted] ? Encryptor.decrypt(value: value, key: Aggregate::Base.encryption_key, iv: Aggregate::Base.iv) : value.to_s
  end

  def encrypt(value)
    Encryptor.encrypt(value: value, key: Aggregate::Base.encryption_key, iv: Aggregate::Base.iv)
  end

  def store(value)
    options[:encrypted] ? encrypt(value) : value
  end

  def assign(value)
    value.to_s
  end

  def validation_errors(value)
    super + [
      ("#{value.class} is too long (maximum is #{options[:size]} characters)" if !options[:size].nil? && value.to_s.size > options[:size])
    ].compact
  end
end
