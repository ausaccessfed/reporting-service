require 'rails_helper'

RSpec.describe ServiceProvider, type: :model do
  context 'validations' do
    subject { build(:service_provider) }

    it { is_expected.to validate_presence_of(:entity_id) }
    it { is_expected.to validate_presence_of(:name) }
  end
end
