require 'rails_helper'

RSpec.describe IdentityProvider, type: :model do
  context 'validations' do
    subject { build(:identity_provider) }

    it { is_expected.to validate_presence_of(:entity_id) }
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_uniqueness_of(:entity_id) }
  end
end
