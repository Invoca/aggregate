# frozen_string_literal: true

class GovernmentTravelItinerary < TravelItinerary
  attr_accessible :foreign_service_approval

  aggregate_attribute :foreign_service_approval, :string
end
