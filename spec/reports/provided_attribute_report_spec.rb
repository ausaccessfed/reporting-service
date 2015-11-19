require 'rails_helper'

RSpec.describe ProvidedAttributeReport do
  let(:type) { 'provided-attribute-report' }
  let(:header) { [%w(Name Supported)] }

  let!(:first_attribute) { create :saml_attribute }
  let!(:second_attribute) { create :saml_attribute }

  let(:identity_provider_01) do
    create :identity_provider, saml_attributes: [first_attribute]
  end

  let(:identity_provider_02) do
    create :identity_provider, saml_attributes: [second_attribute]
  end

  let(:identity_provider_03) do
    create :identity_provider,
           saml_attributes: [first_attribute, second_attribute]
  end

  let!(:identity_providers) do
    { identity_provider_01: identity_provider_01,
      identity_provider_02: identity_provider_02,
      identity_provider_03: identity_provider_03 }
  end

  shared_examples 'an attribute report' do
    subject { ProvidedAttributeReport.new(title) }

    let(:report) { subject.generate }

    it 'produces title, header and type' do
      expect(report).to include(header: header,
                                type: type, title: title)
    end

    it 'should generate an array of report rows' do
      identity_providers.each do |_k, v|
        expect(report[:rows]).to include([v.name, anything])
      end
    end

    it 'determines whether idp is supported or not' do
      supported_idps.each do |k, v|
        expect(report[:rows]).to include([identity_providers[k].name, v])
      end
    end
  end

  context '#generate' do
    context 'first attribute' do
      let(:title) { first_attribute.name }
      let(:supported_idps) do
        { identity_provider_01: 'yes',
          identity_provider_02: 'no',
          identity_provider_03: 'yes' }
      end

      it_behaves_like 'an attribute report'
    end

    context 'second attribute' do
      let(:title) { second_attribute.name }
      let(:supported_idps) do
        { identity_provider_01: 'no',
          identity_provider_02: 'yes',
          identity_provider_03: 'yes' }
      end

      it_behaves_like 'an attribute report'
    end
  end
end
