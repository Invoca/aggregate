# frozen_string_literal: true

module RailsUpgradeHelpers
  class Version
    class << self
      def if_version(rails_4: nil, rails_5: nil)
        case Rails::VERSION::MAJOR
        when 4
          rails_4&.call
        when 5
          rails_5&.call
        when 6
          rails_5&.call
        else
          raise "Unexpected rails major version #{Rails::VERSION::MAJOR} expected 4 or 5"
        end
      end
    end
  end
end
