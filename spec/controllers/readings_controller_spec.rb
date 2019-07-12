require 'rails_helper'

RSpec.describe ReadingsController, type: :controller do
  let(:thermostat) { create(:thermostat) }
  let(:reading)    { create(:reading, thermostat_id: thermostat.id) }

  describe 'POST#create' do
    context 'success' do
      before(:each) do
        post :create,
             params: { temperature: 45.2,
                       humidity: 22.3,
                       battery_charge: 88.7,
                       household_token: thermostat.household_token },
             format: :json
      end
      it { is_expected.to respond_with(:success) }
      it 'respond with stats 200' do
        expect(response.status).to eq(200)
      end
      it 'response with tracking_number 1' do
        expect(JSON.parse(response.body)['tracking_number']).to eq(1)
      end
    end
    context 'fail' do
      before(:each) do
        post :create,
             params: { temperature: 45.2,
                       household_token: thermostat.household_token },
             format: :json
      end
      it 'respond with success false' do
        expect(JSON.parse(response.body)['success']).to eq(false)
      end

      it 'respond with stats 404' do
        expect(response.status).to eq(404)
      end
      it 'response with tracking_number 2' do
        expect(JSON.parse(response.body)['error']).to eq('missing parameter(s)')
      end
    end
  end

  describe 'GET#SHOW' do
    context 'success' do
      before(:each) do
        elastic = Elasticsearch::Client.new url: 'http://localhost:9200', log: true

        elastic.index index: "#{reading.tracking_number}-#{reading.household_token}",
                     type: 'mytype',
                     id: reading.tracking_number,
                     body: { temperature: reading.temperature,
                             humidity: reading.humidity,
                             battery_charge: reading.battery_charge }

        sleep 1
        get :show,
            params: { tracking_number: reading.tracking_number,
                      household_token: thermostat.household_token },
            format: :json
      end
      it { is_expected.to respond_with(:success) }
      it 'respond with stats 200' do
        expect(response.status).to eq(200)
      end
      it 'response with reading data' do
        expect(JSON.parse(response.body)['data']).to match({'temperature'=> reading.temperature, 'humidity'=> reading.humidity, 'battery_charge'=> reading.battery_charge})
      end
    end
    context 'fail' do
      before(:each) do
        get :show,
             params: { household_token: thermostat.household_token },
             format: :json
      end
      it 'respond with success false' do
        expect(JSON.parse(response.body)['success']).to eq(false)
      end

      it 'respond with stats 404' do
        expect(response.status).to eq(404)
      end
      it 'response with error missing params' do
        expect(JSON.parse(response.body)['error']).to eq('missing parameter(s)')
      end
    end
  end
end
