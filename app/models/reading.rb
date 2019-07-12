class Reading < ActiveRecord::Base
  belongs_to :thermostat
  before_destroy :remove_index

  delegate :household_token, to: :thermostat

  validates :thermostat_id,
            :tracking_number,
            :temperature,
            :humidity,
            :battery_charge,
            presence: true

  private

  def remove_index
    elastic = Elasticsearch::Client.new url: 'http://localhost:9200', log: true
    elastic.delete(index: "#{tracking_number}-#{household_token}",
                   id: tracking_number, type: 'mytype')
  end
end
