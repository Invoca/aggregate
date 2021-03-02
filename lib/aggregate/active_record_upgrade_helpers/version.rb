# frozen_string_literal: true

module Aggregate
  module ActiveRecordHelpers
    class Version
      class << self
        def if_version(active_record_4: nil, active_record_gt_4: nil)
          case ActiveRecord::VERSION::MAJOR
          when 4
            active_record_4&.call
          when 5
            active_record_gt_4&.call
          when 6
            active_record_gt_4&.call
          else
            raise "Unexpected rails major version #{ActiveRecord::VERSION::MAJOR} expected 4 or 5"
          end
        end
      end
    end
  end
end
