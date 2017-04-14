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
    attr_accessor :encryption_key, :iv

    def initialize
      # Should be a list made up of hashes that have:
      #   - keys : to encrypt/decrypt
      #     - where to find supported ciphers: https://github.com/attr-encrypted/encryptor
      #
      # Example:
      #
      #  [ {
      #      key  : ''
      #     }, ...
      #  ]
      #

      @keys_list_hash = {}
      @encryption_key = nil
    end
  end
end
