# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceCompatibilityReport do
  subject { described_class.new(service_provider_01.entity_id) }

  let(:type) { 'service-compatibility' }
  let(:header) { [%w[Name Required Optional Compatible]] }

  let(:service_provider_01) { create(:service_provider) }
  let(:core_attributes) { create_list(:saml_attribute, 8, :core_attribute) }
  let(:other_attributes) { create_list(:saml_attribute, 5) }

  let(:identity_provider_01) { create(:identity_provider, saml_attributes: [*core_attributes, *other_attributes]) }

  let(:incompatible_identity_provider) { create(:identity_provider, saml_attributes: core_attributes[0..2]) }

  let(:inactive_identity_provider) do
    create(:identity_provider, saml_attributes: [*core_attributes, *other_attributes])
  end

  before do
    core_attributes.each do |attribute|
      create(
        :service_provider_saml_attribute,
        optional: false,
        saml_attribute: attribute,
        service_provider: service_provider_01
      )
    end

    other_attributes.each do |attribute|
      create(
        :service_provider_saml_attribute,
        optional: true,
        saml_attribute: attribute,
        service_provider: service_provider_01
      )
    end

    create(:activation, federation_object: identity_provider_01)
    create(:activation, federation_object: incompatible_identity_provider)
    create(:activation, federation_object: service_provider_01)
  end

  context 'a service compatibility report' do
    let(:report) { subject.generate }

    it 'must contain type, header, title' do
      expect(report).to include(type:, title: "Service Compatibility for #{service_provider_01.name}", header:)
      expect(report[:rows]).to include([identity_provider_01.name, '8', '5', 'yes'])
      expect(report[:rows]).not_to include([inactive_identity_provider.name, anything, anything, anything])
      expect(report[:rows]).to include([identity_provider_01.name, anything, anything, 'yes'])
      expect(report[:rows]).to include([incompatible_identity_provider.name, anything, anything, 'no'])
    end
  end
end
