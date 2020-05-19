# frozen_string_literal: true

class GovernmentTravelItinerary < TravelItinerary
  aggregate_attribute :foreign_service_approval, :string
end
