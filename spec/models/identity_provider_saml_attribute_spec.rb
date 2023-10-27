# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentityProviderSAMLAttribute do
  context 'validations' do
    subject { create(:identity_provider_saml_attribute) }

    it { is_expected.to validate_presence_of(:identity_provider) }
    it { is_expected.to validate_presence_of(:saml_attribute) }

    it 'requires the attribute to be unique per IdP' do
      expect(subject).to validate_uniqueness_of(:saml_attribute_id).scoped_to(:identity_provider_id)
    end
  end
end
