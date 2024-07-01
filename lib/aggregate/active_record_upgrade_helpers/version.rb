# frozen_string_literal: true

module Aggregate
  module ActiveRecordHelpers
    class Version
      class << self
        def if_version(active_record_4: nil, active_record_gt_4: nil)
          case ActiveRecord::VERSION::MAJOR
          when 4
            active_record_4&.call
          else
            active_record_gt_4&.call
          end
        end
      end
    end
  end
end
