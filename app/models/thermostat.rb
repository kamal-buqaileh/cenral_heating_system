class Thermostat < ActiveRecord::Base
  has_many :readings, dependent: :destroy

  validates :household_token, :location, presence: true
end
