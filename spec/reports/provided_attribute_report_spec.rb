# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProvidedAttributeReport do
  let(:type) { 'provided-attribute' }
  let(:header) { [%w[Name Supported]] }

  let(:first_attribute) { create :saml_attribute }
  let(:second_attribute) { create :saml_attribute }

  let(:identity_provider_01) { create :identity_provider, saml_attributes: [first_attribute] }

  let(:identity_provider_02) { create :identity_provider, saml_attributes: [second_attribute] }

  let(:identity_provider_03) { create :identity_provider, saml_attributes: [first_attribute, second_attribute] }

  let(:active_identity_providers) { { identity_provider_01:, identity_provider_02:, identity_provider_03: } }

  before do
    [identity_provider_01, identity_provider_02, identity_provider_03].each do |o|
      create(:activation, federation_object: o)
    end
  end

  shared_examples 'an attribute report' do
    subject { ProvidedAttributeReport.new(name) }

    let(:report) { subject.generate }

    it 'produces title, header and type' do
      title = "Identity Providers supporting #{name}"
      expect(report).to include(header:, type:, title:)
    end

    it 'determines whether IdP is supported or not' do
      supported_idps.each do |k, v|
        idp_name = active_identity_providers[k].name

        expect(report[:rows]).to include([idp_name, v])
      end
    end
  end

  context '#generate' do
    context 'first attribute' do
      let(:name) { first_attribute.name }
      let(:supported_idps) { { identity_provider_01: 'yes', identity_provider_02: 'no', identity_provider_03: 'yes' } }

      it_behaves_like 'an attribute report'
    end

    context 'second attribute' do
      let(:name) { second_attribute.name }
      let(:supported_idps) { { identity_provider_01: 'no', identity_provider_02: 'yes', identity_provider_03: 'yes' } }

      it_behaves_like 'an attribute report'
    end

    context 'report rows' do
      subject { ProvidedAttributeReport.new('any-name') }

      let(:report) { subject.generate }
      let(:inactive_identity_provider) do
        create :identity_provider, saml_attributes: [first_attribute, second_attribute]
      end

      it 'should never include inactive IdP' do
        idp_name = inactive_identity_provider.name

        expect(report[:rows]).not_to include([idp_name, anything])
      end

      it 'should generate an array of report rows' do
        active_identity_providers.each_value { |v| expect(report[:rows]).to include([v.name, anything]) }
      end
    end
  end
end
