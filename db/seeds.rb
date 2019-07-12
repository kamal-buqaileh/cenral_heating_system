thermostats_locations = %w[location1 location2 location3 location4 location5]

thermostats_locations.each do |location|
  Thermostat.create(location: location, household_token: SecureRandom.hex(10))
end
