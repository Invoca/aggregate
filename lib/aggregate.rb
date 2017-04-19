require "aggregate/bitfield"

require "aggregate/attribute/base"
require "aggregate/attribute/builtin"
require "aggregate/attribute/string"
require "aggregate/attribute/integer"
require "aggregate/attribute/float"
require "aggregate/attribute/boolean"
require "aggregate/attribute/enum"
require "aggregate/attribute/date_time"
require "aggregate/attribute/decimal"
require "aggregate/attribute/nested_aggregate"
require "aggregate/attribute/schema_version"
require "aggregate/attribute/foreign_key"
require "aggregate/attribute/list"
require "aggregate/attribute/bitfield"

require "aggregate/engine"
require "aggregate/aggregate_store"
require "aggregate/attribute_handler"
require "aggregate/base"
require "aggregate/combined_string_field"
require "aggregate/container"

module Aggregate
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset
      @configuration = Configuration.new
    end
  end

  class Configuration
    attr_reader :keys_list

    class Aggregate::ConfigurationError < StandardError; end;

    def keys_list=(keys)
      # Should be a list of base64 encoded keys used for decryption or a single key
      #   - keys : to encrypt/decrypt
      #
      # Example, the list of secret keys below:
      #
      # ["\x11\xD2\xA2\x8F\x8E\xC9!i\xF8\xEEr\x03A\xF3\xA7QvY\x8F\xBCzw\xA7\xE3\xA7;\x86\xAE\xD3\x13\x9F/",
      #  "\xCAE\x1F\xC7<W\xEA\xB4[\xE4'\xCA'\a\x17&\xF2I\x87\x1A\x17\x9B?\x86\xB1A\a%9\xEBZ@",
      #  "#\x13G\xFA\xE5\"\xC0\xCAzL\xE7\x9F\xB0=[\x17>\xF33\xC2\x85\xBF\x16%\a\xE8z:]\xCA1D"]
      #
      # should be stored as:
      #
      # ["EdKij47JIWn47nIDQfOnUXZZj7x6d6fjpzuGrtMTny8=",
      #  "ykUfxzxX6rRb5CfKJwcXJvJJhxoXmz+GsUEHJTnrWkA=",
      # "IxNH+uUiwMp6TOefsD1bFz7zM8KFvxYlB+h6Ol3KMUQ="]
      #
      # * Note * you can set just one base64 encoded string.

      @keys_list = keys
      (@keys_list.nil? || @keys_list.is_a?(String) || @keys_list.is_a?(Array)) or raise Aggregate::ConfigurationError, "keys_list should be nil, String, or an Array"
    end
  end
end
