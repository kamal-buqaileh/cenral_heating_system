require 'rails_helper'

RSpec.describe ThermostatsController, type: :controller do
  let(:thermostat) { create(:thermostat) }
  let(:reading)    { create(:reading, thermostat_id: thermostat.id) }
  let(:reading1)    { create(:reading, thermostat_id: thermostat.id) }
  let(:reading2)    { create(:reading, thermostat_id: thermostat.id) }
  let(:reading3)    { create(:reading, thermostat_id: thermostat.id) }
  describe 'GET#readings_report' do
    context 'success' do
      before(:each) do
        @elastic = Elasticsearch::Client.new url: 'http://localhost:9200', log: true

        [reading, reading1, reading2, reading3].each do |r|
          @elastic.index index: "#{r.tracking_number}-#{r.household_token}",
            type: 'mytype',
            id: r.tracking_number,
            body: { temperature: r.temperature,
                    humidity: r.humidity,
                    battery_charge: r.battery_charge }
        end
        sleep 1
        get :readings_report,
            params: { household_token: thermostat.household_token },
            format: :json
      end
      it { is_expected.to respond_with(:success) }

      it 'respond with stats 200' do
        expect(response.status).to eq(200)
      end

      it 'response with reading data' do
        data = @elastic.search(index: "*-#{thermostat.household_token}",
                    body: {
                      aggs: {
                        max_temperature: {
                          max: {
                            field: 'temperature'
                          }
                        },
                        min_temperature: {
                          min: {
                            field: 'temperature'
                          }
                        },
                        avg_temperature: {
                          avg: {
                            field: 'temperature'
                          }
                        },
                        max_humidity: {
                          max: {
                            field: 'humidity'
                          }
                        },
                        min_humidity: {
                          min: {
                            field: 'humidity'
                          }
                        },
                        avg_humidity: {
                          avg: {
                            field: 'humidity'
                          }
                        },
                        max_battery_charge: {
                          max: {
                            field: 'battery_charge'
                          }
                        },
                        min_battery_charge: {
                          min: {
                            field: 'battery_charge'
                          }
                        },
                        avg_battery_charge: {
                          avg: {
                            field: 'battery_charge'
                          }
                        }
                      }
                    })['aggregations']

        expect(JSON.parse(response.body)['data']).to match(data)
      end
    end
  end
end
