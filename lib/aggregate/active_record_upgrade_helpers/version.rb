# frozen_string_literal: true

module Aggregate
  module ActiveRecordHelpers
    class Version
      class << self
        def if_version(active_record_4: nil, active_record_5: nil, active_record_6: nil)
          case ActiveRecord::VERSION::MAJOR
          when 4
            active_record_4&.call
          when 5
            active_record_5&.call
          when 6
            active_record_6&.call
          else
            raise "Unexpected rails major version #{active_record_4::VERSION::MAJOR} expected 4 or 5"
          end
        end
      end
    end
  end
end
