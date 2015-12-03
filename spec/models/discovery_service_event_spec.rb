require 'rails_helper'

RSpec.describe DiscoveryServiceEvent, type: :model do
  context 'validations' do
    subject { create(:discovery_service_event) }

    it { is_expected.to validate_presence_of(:user_agent) }
<<<<<<< HEAD
    it { is_expected.to validate_presence_of(:service_provider) }
    it { is_expected.to validate_presence_of(:ip) }
    it { is_expected.to validate_presence_of(:unique_id) }
    it { is_expected.to validate_presence_of(:phase) }
=======
    it { is_expected.to validate_presence_of(:ip) }
    it { is_expected.to validate_presence_of(:initiating_sp) }
    it { is_expected.to validate_presence_of(:unique_id) }
    it { is_expected.to validate_presence_of(:phase) }
    it { is_expected.to validate_presence_of(:timestamp) }
>>>>>>> 896b191c8c12d6e421762c347a9eeeade1a653c5
  end
end
