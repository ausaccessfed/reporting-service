# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceProviderSAMLAttribute do
  context 'validations' do
    subject { build(:service_provider_saml_attribute) }

    it { is_expected.to validate_presence_of(:service_provider) }
    it { is_expected.to validate_presence_of(:saml_attribute) }
  end
end
