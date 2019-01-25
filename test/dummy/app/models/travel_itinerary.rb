# frozen_string_literal: true

class TravelItinerary < ActiveRecord::Base
  attr_accessible :aggregate_field

  attr_accessible :estimated_cost

  include Aggregate::Container
  store_aggregates_using :aggregate_field

  aggregate_attribute :estimated_cost, :decimal
  aggregate_has_many :foreign_visits, "ForeignVisit"
end
