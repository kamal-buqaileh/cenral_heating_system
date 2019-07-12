require 'rails_helper'

RSpec.describe Thermostat, type: :model do
  let(:thermostat) { create(:thermostat) }

  describe 'associations' do
    it { is_expected.to have_many(:readings).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_presence_of(:household_token) }
  end
end
