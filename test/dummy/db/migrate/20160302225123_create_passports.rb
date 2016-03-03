class CreatePassports < ActiveRecord::Migration
  def change
    create_table :passports do |t|
      t.string :name

      t.timestamps
    end
  end
end
