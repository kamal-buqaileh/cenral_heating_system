require 'rails_helper'

RSpec.describe Reading, type: :model do
  let(:thermostat) { create(:thermostat) }
  let(:reading)    { create(:reading, thermostat_id: thermostat.id) }

  describe 'associations' do
    it { is_expected.to belong_to(:thermostat) }
  end

  describe 'delegate' do
    it { should delegate_method(:household_token).to(:thermostat) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:thermostat_id) }
    it { is_expected.to validate_presence_of(:tracking_number) }
    it { is_expected.to validate_presence_of(:temperature) }
    it { is_expected.to validate_presence_of(:humidity) }
    it { is_expected.to validate_presence_of(:battery_charge) }
  end

  describe '#remove_index' do
    it 'removes the index from elasticsearch before destrying the record' do
      elastic = Elasticsearch::Client.new url: 'http://localhost:9200', log: true
      elastic.index index: "#{reading.tracking_number}-#{reading.household_token}",
                   type: 'mytype',
                   id: reading.tracking_number,
                   body: { temperature: reading.temperature,
                           humidity: reading.humidity,
                           battery_charge: reading.battery_charge }
      tracking_number, household_token = reading.tracking_number, reading.household_token
      reading.destroy
      expect(elastic.count(index: "#{tracking_number}-#{household_token}", id: tracking_number)['count']).to eq(0)
    end
  end
end
