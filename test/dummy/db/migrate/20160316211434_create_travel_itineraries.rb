class CreateTravelItineraries < (ActiveSupport::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration)
  def change
    create_table :travel_itineraries do |t|
      t.string :type, default: nil
      t.text :aggregate_field

      t.timestamps
    end
  end
end
