class CreateThermostat < ActiveRecord::Migration[5.1]
  def change
    create_table :thermostats do |t|
      t.text :household_token
      t.text :location

      t.timestamps null: false
    end
  end
end
