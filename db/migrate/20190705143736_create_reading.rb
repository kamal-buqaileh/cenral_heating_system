class CreateReading < ActiveRecord::Migration[5.1]
  def change
    create_table :readings do |t|
      t.references :thermostat
      t.integer    :tracking_number
      t.float      :temperature
      t.float      :humidity
      t.float      :battery_charge

      t.timestamps null: false
    end
  end
end
