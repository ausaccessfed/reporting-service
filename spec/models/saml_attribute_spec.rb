require 'rails_helper'

RSpec.describe SAMLAttribute, type: :model do
  context 'validations' do
    subject { build(:saml_attribute) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_uniqueness_of(:name) }

    it do
      is_expected.to validate_inclusion_of(:core)
        .in_array([true, false])
    end
  end
end
