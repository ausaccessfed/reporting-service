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

  let!(:activation) do
    create :activation, federation_object: identity_provider
  end

  subject { IdentityProviderAttributesReport.new }

  context 'a tabular repot which lists IdPs attributes' do
    it 'rows data is an array' do
      expect(subject.rows).to be_a(Array)
    end

    it 'includes report :type, :header, :footer' do
      expect(subject.generate).to include(type: type,
                                          title: title, header: header)
    end

    it '#row sould be :core and :optioanl attributes' do
      expect(subject.rows).to include([identity_provider.name,
                                       '1', '10'])
    end
  end
end
