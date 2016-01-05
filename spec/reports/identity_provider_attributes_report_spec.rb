require 'rails_helper'

RSpec.describe IdentityProviderAttributesReport do
  let(:type) { 'identity-provider-attributes' }
  let(:header) { [['Name', 'Core Attributes', 'Optional Attributes']] }
  let(:title) { 'Identity Provider Attributes' }

  let(:optional_attributes) { create_list :saml_attribute, 10 }
  let(:core_attribute) { create :saml_attribute, :core_attribute }
  let(:all_attributes) { optional_attributes << core_attribute }

  let(:identity_provider) do
    create :identity_provider,
           saml_attributes: all_attributes
  end

  let(:identity_provider_02) do
    create :identity_provider,
           saml_attributes: all_attributes
  end

  subject { IdentityProviderAttributesReport.new }
  let(:report) { subject.generate }

  context 'a tabular report which lists IdPs attributes' do
    let!(:activation) do
      create :activation, federation_object: identity_provider
    end

    it 'rows data is an array' do
      expect(report[:rows]).to be_a(Array)
    end

    it 'includes report :type, :header, :footer' do
      expect(report).to include(type: type,
                                title: title, header: header)
    end

    it '#row should be :core and :optional attributes' do
      expect(report[:rows])
        .to match_array([[identity_provider.name, '1', '10']])
    end

    context 'when there are inactive objects' do
      let!(:inactive_activation) do
        create :activation, :deactivated,
               federation_object: identity_provider_02
      end

      it 'should generate report only for active objects' do
        name = identity_provider_02.name

        expect(report[:rows]).not_to include([name, anything, anything])
      end
    end
  end
end
