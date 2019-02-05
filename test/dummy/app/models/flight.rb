# frozen_string_literal: true

class Flight < ActiveRecord::Base
  attr_accessible :aggregate_field, :passengers

  attr_accessible :flight_number

  include Aggregate::Container
  store_aggregates_using(:aggregate_field)

  aggregate_has_many :passengers, "Passenger"
end
