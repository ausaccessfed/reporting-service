require 'rails_helper'

RSpec.describe RapidConnectService, type: :model do
  context 'validations' do
    subject { build(:rapid_connect_service) }

    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:type) }
  end
end
