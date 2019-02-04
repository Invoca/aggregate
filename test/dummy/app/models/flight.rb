# frozen_string_literal: true

class Flight < ActiveRecord::Base
  attr_accessible :aggregate_field, :passengers

  attr_accessible :flight_number

  include Aggregate::Container
  aggregate_container_options[:use_storage_field] = :aggregate_field

  aggregate_has_many :passengers, "Passenger"
end
