# frozen_string_literal: true

class Passport < ActiveRecord::Base
  include Aggregate::Container
  store_aggregates_using_large_text_field

  aggregate_attribute :gender,           :enum, limit: [:male, :female], required: true
  aggregate_attribute :city,             :string,   required: true
  aggregate_attribute :state,            :string,   required: true
  aggregate_attribute :birthdate,        :datetime, required: true
  aggregate_attribute :height,           :decimal, track_all_values: true
  aggregate_attribute :weight,           :decimal, default: 100
  aggregate_attribute :photo,            "PassportPhoto"
  aggregate_has_many  :foreign_visits,   "ForeignVisit"
  aggregate_attribute :stamps,           :bitfield, limit: 10
  aggregate_attribute :password,         :string,   encrypted: true

  # Test help
  cattr_accessor :initialization_count

  after_initialize do
    self.class.initialization_count ||= 0
    self.class.initialization_count += 1
  end
end
