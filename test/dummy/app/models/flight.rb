# frozen_string_literal: true

class Flight < ActiveRecord::Base
  include Aggregate::Container
  store_aggregates_using(:aggregate_field)

  aggregate_has_many :passengers, "Passenger"
end
