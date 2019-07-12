FactoryBot.define do
  factory :reading do
    tracking_number { Faker::Number.between(1, 10) }
    temperature     { Faker::Number.decimal(2, 3) }
    humidity        { Faker::Number.decimal(2, 3) }
    battery_charge  { Faker::Number.decimal(2, 3) }
  end
end
