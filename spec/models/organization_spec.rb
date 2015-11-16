require 'rails_helper'

RSpec.describe Organization, type: :model do
  context 'validations' do
    subject { build(:organization) }

    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_uniqueness_of(:identifier) }

    it_behaves_like 'a federation object'
  end
end
