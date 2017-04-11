class Aggregate::Attribute::String < Aggregate::Attribute::Builtin

  def self.available_options
    Aggregate::Attribute::Builtin.available_options + [
      :size, # The maximum length of the string
      :encrypted, # Whether or not we need to encrypt a field
    ]
  end

  def load(value)
    secret_key = nil # TODO set secret key in the config
    iv = nil # TODO set this in the config also

    :encrypted ? Encryptor.decrypt(value: value, key: secret_key, iv: iv) : value.to_s
  end

  def encrypt(value)
    secret_key = nil # TODO set secret key in the config
    iv = nil # TODO set this in the config also

    Encryptor.encrypt(value: value, key: secret_key, iv: iv)
  end

  def store(value)
    :encrypted ? encrypt(value) : value
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
