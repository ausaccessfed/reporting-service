require 'rails_helper'

RSpec.describe RapidConnectService, type: :model do
  context 'validations' do
    subject { build(:rapid_connect_service) }

    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:service_type) }

    it { is_expected.to validate_uniqueness_of(:identifier) }
  end
end
