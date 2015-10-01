require 'rails_helper'

RSpec.describe IdentityProviderSAMLAttribute, type: :model do
  context 'validations' do
    subject { build(:identity_provider_saml_attribute) }

    it { is_expected.to validate_presence_of(:identity_provider) }
    it { is_expected.to validate_presence_of(:saml_attribute) }
  end
end
