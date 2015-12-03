require 'rails_helper'

RSpec.describe DiscoveryServiceEvent, type: :model do
  context 'validations' do
    subject { create(:discovery_service_event) }

    it { is_expected.to validate_presence_of(:user_agent) }
    it { is_expected.to validate_presence_of(:service_provider) }
    it { is_expected.to validate_presence_of(:ip) }
    it { is_expected.to validate_presence_of(:unique_id) }
    it { is_expected.to validate_presence_of(:phase) }
  end
end
