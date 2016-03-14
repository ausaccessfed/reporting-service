require 'rails_helper'

RSpec.describe FederatedLoginEvent, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:relying_party) }
    it { is_expected.to validate_presence_of(:asserting_party) }
    it { is_expected.to validate_presence_of(:timestamp) }
    it { is_expected.to validate_presence_of(:result) }
    it { is_expected.to validate_presence_of(:hashed_principal_name) }

    it { is_expected.to validate_uniqueness_of(:hashed_principal_name) }
  end
end
