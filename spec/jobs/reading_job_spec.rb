require 'rails_helper'

RSpec.describe ReadingJob, type: :job do
  let(:thermostat) { create(:thermostat) }
  let(:reading)    { create(:reading, thermostat_id: thermostat.id) }

  subject { ReadingJob.perform_later({ temperature: reading.temperature, humidity: reading.humidity, battery_charge: reading.battery_charge }, thermostat.id) }

  describe '#perform_later' do
    it 'add new record to database' do
      ActiveJob::Base.queue_adapter = :test
      expect { subject }.to have_enqueued_job(ReadingJob)
        .with({ temperature: reading.temperature, humidity: reading.humidity, battery_charge: reading.battery_charge }, thermostat.id)
        .on_queue('default')
    end
  end
end
