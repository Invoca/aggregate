class CreateTravelItineraries < ActiveRecord::Migration
  def change
    create_table :travel_itineraries do |t|
      t.text :aggregate_field

      t.timestamps
    end
  end
end
