require 'rails_helper'

RSpec.describe RequestedAttributeReport do
  let(:type) { 'requested-attribute' }
  let(:header) { [%w(Name Status)] }

  let(:required_attribute) { create :saml_attribute }
  let(:optional_attribute) { create :saml_attribute }
  let(:not_requested_attribute) { create :saml_attribute }

  (1..4).each do |i|
    let("service_provider_0#{i}".to_sym) do
      create :service_provider
    end
  end

  let(:active_service_provders) do
    [service_provider_01, service_provider_02,
     service_provider_03, service_provider_04]
  end

  let(:inacvtive_service_provider) do
    create :service_provider
  end

  before do
    [service_provider_01, service_provider_02].each do |object|
      create :service_provider_saml_attribute,
             optional: false,
             saml_attribute: required_attribute,
             service_provider: object
    end

    [service_provider_03, service_provider_04].each do |object|
      create :service_provider_saml_attribute,
             optional: false,
             saml_attribute: optional_attribute,
             service_provider: object
    end

    active_service_provders.each do |object|
      create :activation, federation_object: object
    end
  end

  shared_examples 'a tabular report for requested attributes' do
    subject { RequestedAttributeReport.new(name) }

    let(:report) { subject.generate }

    it 'rows array should match required size' do
      expect(report[:rows][0].count).to eq(2)
    end

    it 'must contain type' do
      title = "Service Providers requesting #{name}"

      expect(report).to include(type: type, title: title, header: header)
      expect(report[:footer]).not_to be_nil
    end

    it 'should include active SPs only' do
      active_service_provders.each do |sp|
        expect(report[:rows]).to include([sp.name, anything])
      end
    end

    it 'should never include inactive SPs' do
      sp_name = inacvtive_service_provider.name

      expect(report[:rows]).not_to include([sp_name, anything])
    end
  end

  context '#generate' do
    context 'for required attributes' do
      let(:name) { required_attribute.name }

      it_behaves_like 'a tabular report for requested attributes'
    end

    context 'for optional attributes' do
      let(:name) { optional_attribute.name }

      it_behaves_like 'a tabular report for requested attributes'
    end
  end
end
