require 'rails_helper'

RSpec.describe RequestedAttributeReport do
  let(:type) { 'requested-attribute' }
  let(:header) { [%w(Name Status)] }

  let(:required_attribute) { create :saml_attribute }
  let(:optional_attribute) { create :saml_attribute }

  let(:service_provider_01) do
    create :service_provider
  end

  let(:service_provider_02) do
    create :service_provider
  end

  before do
    [service_provider_01, service_provider_02].each do |object|
      create :service_provider_saml_attribute,
             optional: false,
             saml_attribute: required_attribute,
             service_provider: object
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
