class CreateFlights < (ActiveSupport::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration)
  def change
    create_table :flights do |t|
      t.string :flight_number, default: nil
      t.text :aggregate_field

      t.timestamps
    end
  end
end
