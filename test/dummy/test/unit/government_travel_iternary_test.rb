# frozen_string_literal: true

require_relative '../../../test_helper'

class GovernmentTravelItineraryTest < ActiveSupport::TestCase
  context 'initialization' do
    should 'be able to construct a polymorphic class with aggregates defined at multiple levels' do
      itinerary = GovernmentTravelItinerary.create!(estimated_cost: 9001.10, foreign_service_approval: "NSA")
      itinerary.foreign_visits = [ForeignVisit.new(country: 'Spain'), ForeignVisit.new(country: 'Ireland')]
      itinerary.save!

      itinerary = TravelItinerary.find(itinerary.id)
      assert itinerary.is_a?(GovernmentTravelItinerary)

      assert_equal "NSA", itinerary.foreign_service_approval
      assert_equal ['Spain', 'Ireland'], itinerary.foreign_visits.map(&:country)
      expected_json_data = '{"estimated_cost":"9001.1","foreign_visits":[{"country":"Spain"},{"country":"Ireland"}],"foreign_service_approval":"NSA"}'
      assert_equal itinerary.aggregate_field, expected_json_data
    end
  end
end
