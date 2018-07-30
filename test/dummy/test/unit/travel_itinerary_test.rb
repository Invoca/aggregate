# frozen_string_literal: true

require_relative '../../../test_helper'

class TravelItineraryTest < ActiveSupport::TestCase
  context 'initialization' do
    should 'be able to construct a class with aggregates stored in a field' do
      assert_equal :aggregate_field, TravelItinerary.aggregate_container_options[:use_storage_field]
      itinerary = TravelItinerary.create!(estimated_cost: 9001.10)
      itinerary.foreign_visits = [ForeignVisit.new(country: 'Spain'), ForeignVisit.new(country: 'Ireland')]
      itinerary.save!

      itinerary = TravelItinerary.find(itinerary.id)
      assert_equal ['Spain', 'Ireland'], itinerary.foreign_visits.map(&:country)
      expected_json_data = '{"estimated_cost":"9001.1","foreign_visits":[{"country":"Spain"},{"country":"Ireland"}]}'
      assert_equal itinerary.aggregate_field, expected_json_data
      assert_equal '', itinerary.aggregate_store
    end
  end
end
