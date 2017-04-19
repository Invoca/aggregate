class Aggregate::Attribute::String < Aggregate::Attribute::Builtin

  class Aggregate::EncryptionError < StandardError; end;

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
    hash = ActiveSupport::JSON.decode(value)
    Aggregate::Base.secret_keys_from_config.empty? and raise Aggregate::EncryptionError, "must specify a key for decryption"

    find_decrypted_value(Base64.strict_decode64(hash["encrypted_data"]), Base64.strict_decode64(hash["initilization_vector"]))
  end

  def find_decrypted_value(value, iv)
    encrypted_value = nil
    Aggregate::Base.secret_keys_from_config.find do |key|
      begin
        encrypted_value = Encryptor.decrypt(value: value, key: key, iv: iv)
      rescue OpenSSL::Cipher::CipherError
        nil
      end
    end
    encrypted_value or raise Aggregate::EncryptionError, "could not decrypt #{name} because the correct decryption key is not found"
    encrypted_value
  end

  def encrypt(value)
    Aggregate::Base.secret_keys_from_config.empty? and raise Aggregate::EncryptionError, "must specify a key for encryption"

    # Generate random iv, store as hash, encode into JSON safe string
    iv = SecureRandom.random_bytes(12)

    encrypted_data = Encryptor.encrypt(value: value, key: Aggregate::Base.secret_keys_from_config.first, iv: iv)

    ActiveSupport::JSON.encode({ encrypted_data: Base64.strict_encode64(encrypted_data),
                                 initilization_vector: Base64.strict_encode64(iv)
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
