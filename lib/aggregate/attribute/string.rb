class Aggregate::Attribute::String < Aggregate::Attribute::Builtin

  def self.available_options
    Aggregate::Attribute::Builtin.available_options + [
      :size, # The maximum length of the string
      :encrypted, # Whether or not we need to encrypt a field
    ]
  end

  def load(value)
    options[:encrypted] ? decrypt(value) : value.to_s
  end

  def decrypt(value)
    # get string, convert to hash, read decoded iv, decode value, decrypt with iv and value
    hash = ActiveSupport::JSON.decode value

    Encryptor.decrypt(value: Base64.urlsafe_decode64(hash["encrypted_data"]), key: Aggregate::Base.encryption_key, iv: Base64.urlsafe_decode64(hash["initilization_vector"]))
  end

  def encrypt(value)

    # Generate random iv, store as hash, encode into JSON safe string
    iv = SecureRandom.random_bytes(12)
    encrypted_data = Encryptor.encrypt(value: value, key: Aggregate::Base.encryption_key, iv: iv)

    ActiveSupport::JSON.encode({ encrypted_data: Base64.urlsafe_encode64(encrypted_data),
                                 initilization_vector: Base64.urlsafe_encode64(iv)
    })
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
