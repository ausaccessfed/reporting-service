# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceCompatibilityReport do
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

  subject { ServiceCompatibilityReport.new(service_provider_01.entity_id) }

  context 'a service compatibility report' do
    let(:report) { subject.generate }

    it 'must contain type, header, title' do
      title = "Service Compatibility for #{service_provider_01.name}"
      expect(report).to include(type:, title:, header:)
    end

    it 'should count required and optional attributes provider by IdP' do
      name = identity_provider_01.name
      expect(report[:rows]).to include([name, '8', '5', 'yes'])
    end

    it 'should not include inactive IdPs' do
      name = inactive_identity_provider.name
      expect(report[:rows]).not_to include([name, anything, anything, anything])
    end

    it 'should determine whether IdP is compatible or not' do
      name = identity_provider_01.name
      expect(report[:rows]).to include([name, anything, anything, 'yes'])
    end

    it 'should determine whether IdP is compatible or not' do
      name = incompatible_identity_provider.name
      expect(report[:rows]).to include([name, anything, anything, 'no'])
    end
  end
end
