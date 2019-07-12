FactoryBot.define do
  factory :thermostat do
    household_token { SecureRandom.hex(10) }
    location        { Faker::Address.full_address }
  end
end
